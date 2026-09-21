export class SpeechError extends Error {}

export type SpeechOptions = {
  model: string
  keybind: string
  hints: boolean
  maxRecordingSeconds: number
  timeoutSeconds: number
}

export function configure(value: Record<string, unknown> = {}): SpeechOptions {
  const options = {
    model: "gpt-4o-transcribe",
    keybind: "alt+shift+d",
    hints: true,
    maxRecordingSeconds: 120,
    timeoutSeconds: 60,
    ...value,
  }
  if (
    Object.keys(value).some(
      (key) => !["model", "keybind", "hints", "maxRecordingSeconds", "timeoutSeconds"].includes(key),
    )
  ) {
    throw new SpeechError("Unknown speech option.")
  }
  if (typeof options.model !== "string" || !/^gpt-4o(?:-mini)?-transcribe$/.test(options.model)) {
    throw new SpeechError("Speech model must be gpt-4o-transcribe or gpt-4o-mini-transcribe.")
  }
  if (
    typeof options.keybind !== "string" ||
    !/^(?:(?:ctrl|alt|shift|super)\+)+[a-z0-9]$/.test(options.keybind)
  ) {
    throw new SpeechError("Speech keybind must use modifiers and one letter or digit.")
  }
  if (typeof options.hints !== "boolean") {
    throw new SpeechError("Speech hints must be boolean.")
  }
  for (const key of ["maxRecordingSeconds", "timeoutSeconds"] as const) {
    const max = key === "maxRecordingSeconds" ? 120 : 60
    if (!Number.isInteger(options[key]) || options[key] < 1 || options[key] > max) {
      throw new SpeechError(`Speech ${key} must be an integer from 1 to ${max}.`)
    }
  }
  return options as SpeechOptions
}

export function safeMessage(error: unknown, fallback: string) {
  return error instanceof SpeechError ? error.message : fallback
}
