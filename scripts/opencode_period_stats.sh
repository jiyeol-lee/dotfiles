#!/usr/bin/env bash

set -euo pipefail

command -v opencode >/dev/null || {
  printf 'opencode command not found\n' >&2
  exit 1
}

command -v curl >/dev/null || {
  printf 'curl command not found\n' >&2
  exit 1
}

command -v jq >/dev/null || {
  printf 'jq command not found\n' >&2
  exit 1
}

format_int_commas() {
  local value="${1:-0}"
  local sign=""
  local result=""
  local chunk

  [ -n "$value" ] || value="0"

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

format_usd() {
  awk -v value="${1:-0}" 'BEGIN { printf "$%.2f", value + 0 }'
}

column_width() {
  local width="${#1}"
  local value

  shift
  for value in "$@"; do
    if [ "${#value}" -gt "$width" ]; then
      width="${#value}"
    fi
  done

  printf '%s\n' "$width"
}

print_current_month() {
  local sql
  local model_rates_json
  local model_rates_sql
  local query_output
  local query_status
  local row_number=0
  local total_cost_usd="0"
  local input_tokens="0"
  local output_tokens="0"
  local reasoning_tokens="0"
  local cache_read_tokens="0"
  local cache_write_tokens="0"
  local current_day=""
  local field1 field2 field3 field4 field5 field6 field7 field8
  local i j day_index cell_index
  local total_display
  local zero_usd="\$0.00"
  local date_width
  local total_width=5
  local divider
  local cell
  local cell_width
  local -a model_names=()
  local -a model_widths=()
  local -a day_dates=()
  local -a day_totals=()
  local -a day_cells=()
  local -a model_totals=()

  # jq to_entries preserves API order. It is retained as the deterministic secondary
  # sort key when models have equal current-month effective costs.
  model_rates_json="$(
    curl -fsSL https://models.dev/api.json |
      jq -c '.opencode.models | to_entries | map({model_id: .key, cost: (.value.cost | {input, output, cache_read, cache_write})})'
  )"
  model_rates_sql="${model_rates_json//\'/\'\'}"

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
), model_rates AS (
  SELECT
    CAST(rate.key AS INTEGER) AS api_order,
    json_extract(rate.value, '$.model_id') AS model_id,
    COALESCE(CAST(json_extract(rate.value, '$.cost.input') AS REAL), 0) AS input_rate,
    COALESCE(CAST(json_extract(rate.value, '$.cost.output') AS REAL), 0) AS output_rate,
    COALESCE(CAST(json_extract(rate.value, '$.cost.cache_read') AS REAL), 0) AS cache_read_rate,
    COALESCE(CAST(json_extract(rate.value, '$.cost.cache_write') AS REAL), 0) AS cache_write_rate
  FROM json_each('$model_rates_sql') AS rate
), assistant_messages AS (
  SELECT
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
), effective_message_costs AS (
  SELECT
    fm.model_label,
    fm.local_day,
    fm.input_tokens,
    fm.output_tokens,
    fm.reasoning_tokens,
    fm.cache_read_tokens,
    fm.cache_write_tokens,
    CASE
      WHEN fm.cost_usd > 0 THEN fm.cost_usd
      ELSE (
        (fm.input_tokens * COALESCE(mr.input_rate, 0)) +
        (fm.output_tokens * COALESCE(mr.output_rate, 0)) +
        (fm.reasoning_tokens * COALESCE(mr.output_rate, 0)) +
        (fm.cache_read_tokens * COALESCE(mr.cache_read_rate, 0)) +
        (fm.cache_write_tokens * COALESCE(mr.cache_write_rate, 0))
      ) / 1000000.0
    END AS effective_cost_usd
  FROM filtered_messages fm
  LEFT JOIN model_rates mr ON mr.model_id = fm.model_label
), model_monthly AS (
  SELECT model_label AS model, COALESCE(SUM(effective_cost_usd), 0) AS monthly_cost_usd
  FROM effective_message_costs
  GROUP BY model_label
), selected_models AS (
  SELECT
    mm.model,
    mm.monthly_cost_usd,
    COALESCE(mr.api_order, 2147483647) AS model_order
  FROM model_monthly mm
  LEFT JOIN model_rates mr ON mr.model_id = mm.model
), ordered_models AS (
  SELECT
    sm.*,
    ROW_NUMBER() OVER (
      ORDER BY sm.monthly_cost_usd DESC, sm.model_order ASC, sm.model ASC
    ) AS column_order
  FROM selected_models sm
), daily_totals AS (
  SELECT d.day, COALESCE(SUM(emc.effective_cost_usd), 0) AS cost_usd
  FROM days d
  LEFT JOIN effective_message_costs emc ON emc.local_day = d.day
  GROUP BY d.day
), daily_model_costs AS (
  SELECT
    d.day,
    sm.model,
    sm.model_order,
    sm.column_order,
    COALESCE(SUM(emc.effective_cost_usd), 0) AS cost_usd
  FROM days d
  CROSS JOIN ordered_models sm
  LEFT JOIN effective_message_costs emc
    ON emc.local_day = d.day AND emc.model_label = sm.model
  GROUP BY d.day, sm.model, sm.model_order, sm.column_order
), token_totals AS (
  SELECT
    COALESCE(SUM(input_tokens), 0) AS input_tokens,
    COALESCE(SUM(output_tokens), 0) AS output_tokens,
    COALESCE(SUM(reasoning_tokens), 0) AS reasoning_tokens,
    COALESCE(SUM(cache_read_tokens), 0) AS cache_read_tokens,
    COALESCE(SUM(cache_write_tokens), 0) AS cache_write_tokens
  FROM effective_message_costs
)
SELECT * FROM (
SELECT
  'SUMMARY' AS row_type,
  printf('%.6f', COALESCE((SELECT SUM(cost_usd) FROM daily_totals), 0)) AS field2,
  (SELECT today_date FROM bounds) AS field3,
  token_totals.input_tokens AS field4,
  token_totals.output_tokens AS field5,
  token_totals.reasoning_tokens AS field6,
  token_totals.cache_read_tokens AS field7,
  token_totals.cache_write_tokens AS field8
FROM token_totals
UNION ALL
SELECT
  'MODEL',
  model,
  CAST(column_order AS TEXT),
  printf('%.6f', monthly_cost_usd),
  '', '', '', ''
FROM ordered_models
UNION ALL
SELECT
  'DAY',
  dt.day,
  COALESCE(dmc.model, ''),
  printf('%.6f', COALESCE(dmc.cost_usd, 0)),
  printf('%.6f', dt.cost_usd),
  CAST(COALESCE(dmc.column_order, 0) AS TEXT),
  printf('%.6f', COALESCE(sm.monthly_cost_usd, 0)), COALESCE(dmc.model, '')
FROM daily_totals dt
LEFT JOIN daily_model_costs dmc ON dmc.day = dt.day
LEFT JOIN ordered_models sm ON sm.model = dmc.model
)
ORDER BY
  CASE row_type WHEN 'SUMMARY' THEN 1 WHEN 'MODEL' THEN 2 ELSE 3 END,
  CASE WHEN row_type = 'DAY' THEN field2 ELSE '' END DESC,
  -- column_order is assigned from unrounded effective monthly costs; API order
  -- then model name make otherwise equal costs deterministic.
  CASE WHEN row_type = 'MODEL' THEN CAST(field3 AS INTEGER) ELSE CAST(field6 AS INTEGER) END,
  CASE WHEN row_type = 'DAY' THEN field8 ELSE field2 END;
"

  if query_output="$(opencode db "$sql" --format tsv)"; then
    :
  else
    query_status=$?
    printf 'opencode db query failed\n' >&2
    return "$query_status"
  fi

  while IFS=$'\t' read -r field1 field2 field3 field4 field5 field6 field7 field8; do
    if [ "$row_number" -eq 0 ]; then
      row_number=1
      continue
    fi

    case "$field1" in
    SUMMARY)
      total_cost_usd="$field2"
      input_tokens="$field4"
      output_tokens="$field5"
      reasoning_tokens="$field6"
      cache_read_tokens="$field7"
      cache_write_tokens="$field8"
      ;;
    MODEL)
      model_names+=("$field2")
      model_widths+=("${#field2}")
      model_totals+=("$(format_usd "$field4")")
      ;;
    DAY)
      if [ "$field2" != "$current_day" ]; then
        current_day="$field2"
        day_dates+=("$field2")
        day_totals+=("$(format_usd "$field5")")
      fi
      if [ -n "$field3" ]; then
        day_cells+=("$(format_usd "$field4")")
      fi
      ;;
    esac
  done <<<"$query_output"

  total_display="$(format_usd "$total_cost_usd")"
  date_width="$(column_width 'YYYY-MM-DD' "${day_dates[@]}")"

  for cell in "${day_totals[@]}"; do
    [ "${#cell}" -le "$total_width" ] || total_width="${#cell}"
  done
  [ "${#total_display}" -le "$total_width" ] || total_width="${#total_display}"

  for ((i = 0; i < ${#model_names[@]}; i++)); do
    for ((j = 0; j < ${#day_dates[@]}; j++)); do
      cell_index=$((j * ${#model_names[@]} + i))
      cell="${day_cells[$cell_index]:-$zero_usd}"
      cell_width=${#cell}
      if [ "$cell_width" -gt "${model_widths[$i]}" ]; then
        printf -v "model_widths[$i]" '%s' "$cell_width"
      fi
    done
    cell_width="${#model_totals[$i]}"
    if [ "$cell_width" -gt "${model_widths[$i]}" ]; then
      printf -v "model_widths[$i]" '%s' "$cell_width"
    fi
  done

  printf 'Per-day monthly cost:\n'
  divider='+'
  # Each cell has one leading and one trailing space in addition to its content
  # width, so divider segments must include both padding columns.
  printf -v cell '%*s' "$((date_width + 2))" ''
  divider+="${cell// /-}+"
  for ((i = 0; i < ${#model_names[@]}; i++)); do
    printf -v cell '%*s' "$((model_widths[i] + 2))" ''
    divider+="${cell// /-}+"
  done
  printf -v cell '%*s' "$((total_width + 2))" ''
  divider+="${cell// /-}+"

  printf '%s\n' "$divider"
  printf '| %-*s' "$date_width" 'YYYY-MM-DD'
  for ((i = 0; i < ${#model_names[@]}; i++)); do
    printf ' | %-*s' "${model_widths[$i]}" "${model_names[$i]}"
  done
  printf ' | %-*s |\n' "$total_width" 'Total'
  printf '%s\n' "$divider"

  for ((day_index = 0; day_index < ${#day_dates[@]}; day_index++)); do
    printf '| %-*s' "$date_width" "${day_dates[$day_index]}"
    for ((i = 0; i < ${#model_names[@]}; i++)); do
      cell_index=$((day_index * ${#model_names[@]} + i))
      printf ' | %*s' "${model_widths[$i]}" "${day_cells[$cell_index]:-$zero_usd}"
    done
    printf ' | %*s |\n' "$total_width" "${day_totals[$day_index]}"
    printf '%s\n' "$divider"
  done
  printf '| %-*s' "$date_width" 'Total'
  for ((i = 0; i < ${#model_names[@]}; i++)); do
    printf ' | %*s' "${model_widths[$i]}" "${model_totals[$i]}"
  done
  printf ' | %*s |\n' "$total_width" "$total_display"
  printf '%s\n' "$divider"
  printf '\n'

  printf 'Monthly tokens:\n'
  printf '  %-12s %12s\n' 'Input' "$(format_int_commas "$input_tokens")"
  printf '  %-12s %12s\n' 'Output' "$(format_int_commas "$output_tokens")"
  printf '  %-12s %12s\n' 'Reasoning' "$(format_int_commas "$reasoning_tokens")"
  printf '  %-12s %12s\n' 'Cached read' "$(format_int_commas "$cache_read_tokens")"
  printf '  %-12s %12s\n' 'Cached write' "$(format_int_commas "$cache_write_tokens")"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  print_current_month
fi
