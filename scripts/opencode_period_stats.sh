#!/usr/bin/env bash

set -euo pipefail

command -v opencode >/dev/null || {
  echo "opencode command not found" >&2
  exit 1
}

BAR_MAX_WIDTH=30
COLOR_GREEN=$'\033[32m'
COLOR_YELLOW=$'\033[33m'
COLOR_CYAN=$'\033[36m'
COLOR_RESET=$'\033[0m'

format_int_commas() {
  local value="${1:-0}"
  local sign=""
  local result=""
  local chunk

  if [ -z "$value" ]; then
    value="0"
  fi

  if [[ "$value" == -* ]]; then
    sign="-"
    value="${value#-}"
  fi

  while [ "${#value}" -gt 3 ]; do
    chunk="${value: -3}"
    value="${value:0:${#value}-3}"
    if [ -z "$result" ]; then
      result="$chunk"
    else
      result="$chunk,$result"
    fi
  done

  if [ -z "$result" ]; then
    printf '%s%s\n' "$sign" "$value"
  else
    printf '%s%s,%s\n' "$sign" "$value" "$result"
  fi
}

bar_color_for_order() {
  case "$1" in
  1) printf '%s' "$COLOR_GREEN" ;;
  2) printf '%s' "$COLOR_YELLOW" ;;
  3) printf '%s' "$COLOR_CYAN" ;;
  *) printf '' ;;
  esac
}

colored_hash() {
  local order="$1"
  local color
  color="$(bar_color_for_order "$order")"

  if [ -n "$color" ]; then
    printf '%s#%s' "$color" "$COLOR_RESET"
  else
    printf '#'
  fi
}

append_hashes() {
  local count="$1"
  local order="$2"
  local color
  local i

  [ "$count" -gt 0 ] || return 0

  color="$(bar_color_for_order "$order")"
  if [ -n "$color" ]; then
    printf '%s' "$color"
  fi

  i=0
  while [ "$i" -lt "$count" ]; do
    printf '#'
    i=$((i + 1))
  done

  if [ -n "$color" ]; then
    printf '%s' "$COLOR_RESET"
  fi
}

daily_bar_width() {
  local day_total="$1"
  local max_daily="$2"

  awk -v total="$day_total" -v max="$max_daily" -v cap="$BAR_MAX_WIDTH" '
    BEGIN {
      if (total <= 0 || max <= 0) {
        print 1
        exit
      }

      width = int((total / max * cap) + 0.5)
      if (width < 1) width = 1
      if (width > cap) width = cap
      print width
    }
  '
}

render_stacked_bar() {
  local total="$1"
  local width="$2"
  shift 2
  local specs=("$@")
  local allocations
  local idx
  local chars
  local order

  if awk -v total="$total" 'BEGIN { exit !(total <= 0) }'; then
    printf '#'
    return 0
  fi

  allocations="$(printf '%s\n' "${specs[@]}" | awk -v total="$total" -v width="$width" -F $'\t' '
    {
      idx = NR
      cost[idx] = $1 + 0
      order[idx] = $2 + 0
      raw = (total > 0) ? (cost[idx] / total * width) : 0
      chars[idx] = int(raw)
      rem[idx] = raw - chars[idx]
      used += chars[idx]
      n = idx
    }
    END {
      leftover = width - used
      while (leftover > 0) {
        best = 0
        for (i = 1; i <= n; i++) {
          if (best == 0 || rem[i] > rem[best] || (rem[i] == rem[best] && order[i] < order[best])) {
            best = i
          }
        }
        if (best == 0) break
        chars[best]++
        rem[best] = -1
        leftover--
      }
      for (i = 1; i <= n; i++) {
        print i "\t" chars[i] "\t" order[i]
      }
    }
  ')"

  while IFS=$'\t' read -r idx chars order; do
    [ -n "${idx:-}" ] || continue
    append_hashes "$chars" "$order"
  done <<<"$allocations"
}

print_day_row() {
  local day="$1"
  local day_total="$2"
  local max_daily="$3"
  shift 3
  local specs=("$@")
  local amount
  local width
  local bar

  amount="$(awk -v value="$day_total" 'BEGIN { printf "%.2f", value }')"
  width="$(daily_bar_width "$day_total" "$max_daily")"
  bar="$(render_stacked_bar "$day_total" "$width" "${specs[@]}")"

  printf '%-10s | $%-5s | %s\n' "$day" "$amount" "$bar"
}

print_current_month() {
  local sql
  local row_number=0
  local total_cost_usd="0"
  local max_daily_cost_usd="0"
  local input_tokens="0"
  local output_tokens="0"
  local reasoning_tokens="0"
  local cache_read_tokens="0"
  local cache_write_tokens="0"
  local current_day=""
  local current_day_total="0"
  local day_specs=()
  local day_rows=()
  local legend_orders=()
  local legend_names=()
  local field1 field2 field3 field4 field5 field6 field7 field8

  # Static fallback rates, in USD per 1,000,000 tokens.
  # Reasoning tokens are billed as output tokens. Cache-write tokens are
  # included only for models with a provided cache-write rate.
  local gpt55_input_usd_per_million="5.00"
  local gpt55_output_usd_per_million="30.00"
  local gpt55_cached_read_usd_per_million="0.50"
  local opus48_input_usd_per_million="5.00"
  local opus48_output_usd_per_million="25.00"
  local opus48_cached_read_usd_per_million="0.50"
  local opus48_cache_write_usd_per_million="6.25"
  local kimi_k27_code_input_usd_per_million="0.95"
  local kimi_k27_code_output_usd_per_million="4.00"
  local kimi_k27_code_cached_read_usd_per_million="0.19"
  local glm52_input_usd_per_million="1.40"
  local glm52_output_usd_per_million="4.40"
  local glm52_cached_read_usd_per_million="0.26"

  sql="
WITH bounds AS (
  SELECT
    date('now', 'localtime', 'start of month') AS start_date,
    date('now', 'localtime') AS today_date,
    CAST(strftime('%s', datetime('now', 'localtime', 'start of month'), 'utc') AS INTEGER) * 1000 AS start_ms,
    CAST(strftime('%s', datetime('now', 'localtime', 'start of day', '+1 day'), 'utc') AS INTEGER) * 1000 AS end_ms
), days(day) AS (
  SELECT start_date FROM bounds
  UNION ALL
  SELECT date(day, '+1 day')
  FROM days, bounds
  WHERE day < bounds.today_date
), assistant_messages AS (
  SELECT
    COALESCE(NULLIF(json_extract(m.data, '$.providerID'), ''), 'unknown-provider') AS provider_label,
    COALESCE(NULLIF(json_extract(m.data, '$.modelID'), ''), 'unknown-model') AS model_label,
    COALESCE(CAST(json_extract(m.data, '$.cost') AS REAL), 0) AS cost_usd,
    COALESCE(CAST(json_extract(m.data, '$.tokens.input') AS INTEGER), 0) AS input_tokens,
    COALESCE(CAST(json_extract(m.data, '$.tokens.output') AS INTEGER), 0) AS output_tokens,
    COALESCE(CAST(json_extract(m.data, '$.tokens.reasoning') AS INTEGER), 0) AS reasoning_tokens,
    COALESCE(CAST(json_extract(m.data, '$.tokens.cache.read') AS INTEGER), 0) AS cache_read_tokens,
    COALESCE(CAST(json_extract(m.data, '$.tokens.cache.write') AS INTEGER), 0) AS cache_write_tokens,
    COALESCE(m.time_created, s.time_updated) AS effective_time_ms
  FROM message m
  JOIN \"session\" s ON s.id = m.session_id
  WHERE json_extract(m.data, '$.role') = 'assistant'
), filtered_messages AS (
  SELECT
    am.*,
    date(CAST(am.effective_time_ms / 1000 AS INTEGER), 'unixepoch', 'localtime') AS local_day
  FROM assistant_messages am
  CROSS JOIN bounds b
  WHERE am.effective_time_ms >= b.start_ms
    AND am.effective_time_ms < b.end_ms
), message_costs AS (
  SELECT
    provider_label,
    model_label,
    local_day,
    cost_usd,
    input_tokens,
    output_tokens,
    reasoning_tokens,
    cache_read_tokens,
    cache_write_tokens,
    (input_tokens + output_tokens + reasoning_tokens + cache_read_tokens + cache_write_tokens) AS total_tokens,
    lower(model_label) AS lower_model
  FROM filtered_messages
), priced_message_costs AS (
  SELECT
    provider_label,
    model_label,
    local_day,
    cost_usd,
    input_tokens,
    output_tokens,
    reasoning_tokens,
    cache_read_tokens,
    cache_write_tokens,
    total_tokens,
    CASE
      WHEN lower_model LIKE '%gpt-5.5%'
        OR lower_model LIKE '%gpt-five-five%'
      THEN 'gpt-5.5'
      WHEN lower_model LIKE '%claude-opus-4-8%'
        OR lower_model LIKE '%claude-opus-4.8%'
        OR lower_model LIKE '%claude-opus-4_8%'
        OR lower_model LIKE '%claude-opus-48%'
      THEN 'claude-opus-4.8'
      WHEN lower_model LIKE '%kimi-k2.7-code%'
        OR lower_model LIKE '%kimi-k2-7-code%'
        OR lower_model LIKE '%kimi-k2_7-code%'
        OR lower_model LIKE '%kimi-k27-code%'
      THEN 'kimi-k2.7-code'
      WHEN lower_model LIKE '%glm-5.2%'
        OR lower_model LIKE '%glm-5-2%'
        OR lower_model LIKE '%glm-5_2%'
        OR lower_model LIKE '%glm52%'
      THEN 'glm-5.2'
      ELSE ''
    END AS pricing_rule
  FROM message_costs
), effective_message_costs AS (
  SELECT
    provider_label,
    model_label,
    local_day,
    input_tokens,
    output_tokens,
    reasoning_tokens,
    cache_read_tokens,
    cache_write_tokens,
    CASE
      WHEN cost_usd > 0 THEN cost_usd
      WHEN total_tokens = 0 THEN 0
      WHEN pricing_rule = 'gpt-5.5' THEN (
        (input_tokens * $gpt55_input_usd_per_million) +
        ((output_tokens + reasoning_tokens) * $gpt55_output_usd_per_million) +
        (cache_read_tokens * $gpt55_cached_read_usd_per_million)
      ) / 1000000.0
      WHEN pricing_rule = 'claude-opus-4.8' THEN (
        (input_tokens * $opus48_input_usd_per_million) +
        ((output_tokens + reasoning_tokens) * $opus48_output_usd_per_million) +
        (cache_read_tokens * $opus48_cached_read_usd_per_million) +
        (cache_write_tokens * $opus48_cache_write_usd_per_million)
      ) / 1000000.0
      WHEN pricing_rule = 'kimi-k2.7-code' THEN (
        (input_tokens * $kimi_k27_code_input_usd_per_million) +
        ((output_tokens + reasoning_tokens) * $kimi_k27_code_output_usd_per_million) +
        (cache_read_tokens * $kimi_k27_code_cached_read_usd_per_million)
      ) / 1000000.0
      WHEN pricing_rule = 'glm-5.2' THEN (
        (input_tokens * $glm52_input_usd_per_million) +
        ((output_tokens + reasoning_tokens) * $glm52_output_usd_per_million) +
        (cache_read_tokens * $glm52_cached_read_usd_per_million)
      ) / 1000000.0
      ELSE 0
    END AS effective_cost_usd
  FROM priced_message_costs
), model_monthly AS (
  SELECT
    model_label AS model,
    COALESCE(SUM(effective_cost_usd), 0) AS monthly_cost_usd
  FROM effective_message_costs
  GROUP BY model_label
), ranked_models AS (
  SELECT
    mm.model,
    mm.monthly_cost_usd,
    1 + (
      SELECT COUNT(*)
      FROM model_monthly other
      WHERE other.monthly_cost_usd > mm.monthly_cost_usd
        OR (other.monthly_cost_usd = mm.monthly_cost_usd AND other.model < mm.model)
    ) AS model_rank
  FROM model_monthly mm
), grouped_model_monthly AS (
  SELECT
    CASE WHEN model_rank <= 3 THEN model ELSE 'Other' END AS group_name,
    CASE WHEN model_rank <= 3 THEN model_rank ELSE 4 END AS group_order,
    COALESCE(SUM(monthly_cost_usd), 0) AS monthly_cost_usd
  FROM ranked_models
  GROUP BY group_name, group_order
), daily_group_costs AS (
  SELECT
    emc.local_day AS day,
    CASE WHEN rm.model_rank <= 3 THEN rm.model ELSE 'Other' END AS group_name,
    CASE WHEN rm.model_rank <= 3 THEN rm.model_rank ELSE 4 END AS group_order,
    COALESCE(SUM(emc.effective_cost_usd), 0) AS cost_usd
  FROM effective_message_costs emc
  JOIN ranked_models rm ON rm.model = emc.model_label
  GROUP BY emc.local_day, group_name, group_order
), daily_totals AS (
  SELECT
    d.day,
    COALESCE(SUM(dgc.cost_usd), 0) AS cost_usd
  FROM days d
  LEFT JOIN daily_group_costs dgc ON dgc.day = d.day
  GROUP BY d.day
), token_totals AS (
  SELECT
    COALESCE(SUM(input_tokens), 0) AS input_tokens,
    COALESCE(SUM(output_tokens), 0) AS output_tokens,
    COALESCE(SUM(reasoning_tokens), 0) AS reasoning_tokens,
    COALESCE(SUM(cache_read_tokens), 0) AS cache_read_tokens,
    COALESCE(SUM(cache_write_tokens), 0) AS cache_write_tokens
  FROM effective_message_costs
), summary AS (
  SELECT
    COALESCE(SUM(cost_usd), 0) AS total_cost_usd,
    COALESCE(MAX(cost_usd), 0) AS max_daily_cost_usd
  FROM daily_totals
)
SELECT
  'SUMMARY' AS row_type,
  printf('%.6f', summary.total_cost_usd),
  printf('%.6f', summary.max_daily_cost_usd),
  token_totals.input_tokens,
  token_totals.output_tokens,
  token_totals.reasoning_tokens,
  token_totals.cache_read_tokens,
  token_totals.cache_write_tokens
FROM summary
CROSS JOIN token_totals
UNION ALL
SELECT
  'LEGEND',
  CAST(group_order AS TEXT),
  group_name,
  printf('%.6f', monthly_cost_usd),
  '',
  '',
  '',
  ''
FROM grouped_model_monthly
UNION ALL
SELECT
  'DAY',
  dt.day,
  printf('%.6f', dt.cost_usd),
  COALESCE(CAST(dgc.group_order AS TEXT), ''),
  COALESCE(dgc.group_name, ''),
  COALESCE(printf('%.6f', dgc.cost_usd), ''),
  '',
  ''
FROM daily_totals dt
LEFT JOIN daily_group_costs dgc ON dgc.day = dt.day
ORDER BY row_type DESC, 2, 4;
"

  while IFS=$'\t' read -r field1 field2 field3 field4 field5 field6 field7 field8; do
    if [ "$row_number" -eq 0 ]; then
      row_number=1
      continue
    fi

    case "$field1" in
    SUMMARY)
      total_cost_usd="$field2"
      max_daily_cost_usd="$field3"
      input_tokens="$field4"
      output_tokens="$field5"
      reasoning_tokens="$field6"
      cache_read_tokens="$field7"
      cache_write_tokens="$field8"
      ;;
    LEGEND)
      legend_orders+=("$field2")
      legend_names+=("$field3")
      ;;
    DAY)
      if [ -n "$current_day" ] && [ "$field2" != "$current_day" ]; then
        day_rows+=("$(print_day_row "$current_day" "$current_day_total" "$max_daily_cost_usd" "${day_specs[@]}")")
        day_specs=()
      fi

      current_day="$field2"
      current_day_total="$field3"
      if [ -n "$field4" ]; then
        day_specs+=("$field6"$'\t'"$field4"$'\t'"$field5")
      fi
      ;;
    esac
  done < <(opencode db "$sql" --format tsv)

  local total_display
  total_display="$(awk -v value="$total_cost_usd" 'BEGIN { printf "%.2f", value }')"

  if [ -n "$current_day" ]; then
    day_rows+=("$(print_day_row "$current_day" "$current_day_total" "$max_daily_cost_usd" "${day_specs[@]}")")
  fi

  printf 'Current month total: $%s\n' "$total_display"
  printf '\n'

  printf 'Legend:\n'
  if [ "${#legend_names[@]}" -eq 0 ]; then
    printf '  # none\n'
  else
    local i
    i=0
    while [ "$i" -lt "${#legend_names[@]}" ]; do
      printf '  %s %s\n' "$(colored_hash "${legend_orders[$i]}")" "${legend_names[$i]}"
      i=$((i + 1))
    done
  fi
  printf '\n'

  printf 'Per-day monthly cost:\n'
  if [ "${#day_rows[@]}" -gt 0 ]; then
    local row
    for row in "${day_rows[@]}"; do
      printf '%s\n' "$row"
    done
  fi
  printf '\n'

  printf 'Monthly tokens:\n'
  printf '  %-12s %12s\n' 'Input' "$(format_int_commas "$input_tokens")"
  printf '  %-12s %12s\n' 'Output' "$(format_int_commas "$output_tokens")"
  printf '  %-12s %12s\n' 'Reasoning' "$(format_int_commas "$reasoning_tokens")"
  printf '  %-12s %12s\n' 'Cached read' "$(format_int_commas "$cache_read_tokens")"
  printf '  %-12s %12s\n' 'Cached write' "$(format_int_commas "$cache_write_tokens")"
}

print_current_month
