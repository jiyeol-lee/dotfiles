import { mkdtemp, chmod, open, readFile, rm } from "node:fs/promises"
import { rmSync } from "node:fs"
import { constants, tmpdir } from "node:os"
import { join } from "node:path"
import { SpeechError, type SpeechOptions } from "./config"

export type Recording = {
  stop(): Promise<Uint8Array>
  dispose(): Promise<void>
  exited: Promise<number>
  failure?(): Promise<SpeechError>
}

type RecorderProcess = Pick<ReturnType<typeof Bun.spawn>, "exitCode" | "signalCode" | "exited" | "kill">
function schedule(callback: () => void, milliseconds: number) {
  const timer = setTimeout(callback, milliseconds)
  return () => clearTimeout(timer)
}

// Only recorder stderr is retained, in memory. Keep draining after the capture fills.
export function captureRecorderStderr(stream: ReadableStream<Uint8Array>, secrets: string[]) {
  const reader = stream.getReader()
  const bytes = new Uint8Array(8192)
  let length = 0
  let truncated = false
  let complete = false
  let finishing: Promise<void> | undefined
  const drained = (async () => {
    try {
      while (true) {
        const { done, value } = await reader.read()
        if (done) {
          complete = true
          break
        }
        const size = Math.min(value.length, bytes.length - length)
        bytes.set(value.subarray(0, size), length)
        length += size
        if (size < value.length) {
          truncated = true
        }
      }
    } catch {
      truncated = true
    } finally {
      reader.releaseLock()
    }
  })()
  const redact = (text: string) => {
    for (const secret of secrets.filter(Boolean).sort((a, b) => b.length - a.length)) {
      text = text.split(secret).join("[redacted]")
      // The capture boundary can cut a secret in half. Never display that suffix.
      if (truncated) {
        for (let size = Math.min(secret.length - 1, text.length); size > 0; size--) {
          if (text.endsWith(secret.slice(0, size))) {
            text = text.slice(0, -size) + "[redacted]"
            break
          }
        }
      }
    }
    return text
  }
  return {
    hasOnlyExpectedOutput(path: string) {
      const text = new TextDecoder().decode(bytes.subarray(0, length)).trim()
      return complete && !truncated && (text === "" || text === path)
    },
    snippet() {
      // Ignore an incomplete UTF-8 tail so prefix redaction is not defeated by U+FFFD.
      const text = redact(
        redact(new TextDecoder().decode(bytes.subarray(0, length), { stream: true }))
          // Strip complete and unfinished terminal strings, CSI and short escapes.
          .replace(/(?:\x1b\]|\x9d)[\s\S]*?(?:\x07|\x1b\\|\x9c|$)/g, "")
          .replace(/(?:\x1b[P^_X]|[\x90\x98\x9e\x9f])[\s\S]*?(?:\x1b\\|\x9c|$)/g, "")
          .replace(/(?:\x1b\[|\x9b)[0-?]*[ -/]*(?:[@-~]|$)/g, "")
          .replace(/\x1b[ -/]*[0-~]?/g, "")
          .replace(/[\r\n\t]/g, " ")
          .replace(/[\x00-\x1f\x7f-\x9f\u200b-\u200f\u202a-\u202e\u2060-\u206f\ufeff]/g, ""),
      )
        .replace(/\s+/g, " ")
        .trim()
      if (!text) {
        return ""
      }
      return text.length > 512 || truncated ? text.slice(0, 511) + "…" : text
    },
    finish() {
      return finishing ??= (async () => {
        let cancel = () => {}
        try {
          await Promise.race([
            drained,
            new Promise<void>(resolve => {
              cancel = schedule(() => {
                truncated = true
                resolve()
              }, 100)
            }),
          ])
        } finally {
          cancel()
          // Cancellation itself may never settle for a broken pipe. Do not await it.
          void reader.cancel().catch(() => {})
        }
      })()
    },
  }
}

type RecorderDiagnostics = ReturnType<typeof captureRecorderStderr>

export function recorderLifecycle(
  proc: RecorderProcess,
  cleanup: () => Promise<void>,
  diagnostics: RecorderDiagnostics,
  expectedFilename: string,
) {
  let stopRequested = false
  let unexpected = false
  let stopped: Promise<void> | undefined
  let disposal: Promise<void> | undefined
  void proc.exited.then(
    () => {
      if (!stopRequested) {
        unexpected = true
      }
    },
    () => {
      unexpected = true
    },
  )
  const failure = (reason: string, code = proc.exitCode) => {
    const exit = Number.isSafeInteger(code) ? code : "unknown"
    const signal = proc.signalCode === null ? "none" : constants.signals[proc.signalCode] ?? "unknown"
    return new SpeechError(`${reason} (exit=${exit}, signal=${signal}). Recording discarded.`)
  }
  const diagnostic = (error: SpeechError) => {
    const snippet = diagnostics.snippet()
    return snippet ? new SpeechError(`${error.message} pw-record stderr: ${snippet}`) : error
  }
  const stop = () => stopped ??= (async () => {
    if (unexpected || proc.exitCode !== null || proc.signalCode !== null) {
      throw failure("Recorder exited unexpectedly")
    }
    stopRequested = true
    let cancel = () => {}
    let forced = false
    try {
      try {
        proc.kill("SIGINT")
      } catch {
        // Do not leave the microphone running if the initial signal cannot be sent.
        try {
          proc.kill("SIGKILL")
        } catch {
        }
        throw failure("Recorder failed")
      }
      const timeout = new Promise<never>((_resolve, reject) => {
        cancel = schedule(() => {
          // A timer must settle even if kill throws or the child never reports an exit.
          forced = true
          try {
            proc.kill("SIGKILL")
          } catch {
          }
          reject(failure("Recorder stop timed out; SIGKILL requested"))
        }, 2000)
      })
      const code = await Promise.race([proc.exited, timeout])
      if (forced) {
        throw failure("Recorder stop timed out; SIGKILL requested", code)
      }
      if (unexpected) {
        throw failure("Recorder exited unexpectedly", code)
      }
      await diagnostics.finish()
      if (forced) {
        throw failure("Recorder stop timed out; SIGKILL requested", code)
      }
      const exitCode = proc.exitCode ?? code
      // PipeWire 1.6.8 prints the path; 1.6.9 is silent. Both can leave exit 1 on
      // SIGINT without data.drained, but sf_close still finalizes the WAV.
      // https://github.com/PipeWire/pipewire/blob/1.6.9/src/tools/pw-cat.c
      const expectedStopOutput = exitCode === 1 && diagnostics.hasOnlyExpectedOutput(expectedFilename)
      const expected =
        proc.signalCode === "SIGINT" ||
        (proc.signalCode === null && (exitCode === 0 || exitCode === 130 || expectedStopOutput))
      if (!expected) {
        throw failure("Recorder failed", exitCode)
      }
    } catch (error) {
      if (forced) {
        throw failure("Recorder stop timed out; SIGKILL requested")
      }
      if (error instanceof SpeechError) {
        throw error
      }
      throw failure("Recorder failed")
    } finally {
      cancel()
    }
  })().catch(async error => {
    await diagnostics.finish()
    throw diagnostic(error)
  })
  return {
    stop,
    async failure() {
      await diagnostics.finish()
      return diagnostic(failure("Recorder exited unexpectedly"))
    },
    dispose() {
      return disposal ??= (async () => {
        try {
          await stop().catch(() => {})
        } finally {
          await cleanup()
        }
      })()
    },
  }
}

// Reject unfinished headers and malformed chunks rather than repairing recordings.
export function validateWav(audio: Uint8Array): void {
  if (audio.byteLength <= 44 || audio.byteLength > 25_000_000) {
    throw new SpeechError("Recording is empty or too large.")
  }
  const invalid = () => {
    throw new SpeechError("Recording is not a complete PCM16 16000 Hz mono WAV. Recording discarded.")
  }
  const view = new DataView(audio.buffer, audio.byteOffset, audio.byteLength)
  const tag = (offset: number) => String.fromCharCode(...audio.subarray(offset, offset + 4))
  if (tag(0) !== "RIFF" || tag(8) !== "WAVE" || view.getUint32(4, true) !== audio.byteLength - 8) {
    invalid()
  }
  let format = false
  let data = false
  let offset = 12
  while (offset < audio.byteLength) {
    if (audio.byteLength - offset < 8) {
      invalid()
    }
    const size = view.getUint32(offset + 4, true)
    const start = offset + 8
    const end = start + size
    const next = end + (size % 2)
    if (next > audio.byteLength) {
      invalid()
    }
    if (tag(offset) === "fmt ") {
      if (format || data || size < 16) {
        invalid()
      }
      if (
        view.getUint16(start, true) !== 1 ||
        view.getUint16(start + 2, true) !== 1 ||
        view.getUint32(start + 4, true) !== 16000 ||
        view.getUint32(start + 8, true) !== 32000 ||
        view.getUint16(start + 12, true) !== 2 ||
        view.getUint16(start + 14, true) !== 16
      ) {
        invalid()
      }
      if (size !== 16 && (size < 18 || view.getUint16(start + 16, true) !== size - 18)) {
        invalid()
      }
      format = true
    } else if (tag(offset) === "data") {
      if (!format || data || size === 0 || size % 2 !== 0) {
        invalid()
      }
      data = true
    }
    offset = next
  }
  if (!format || !data) {
    invalid()
  }
}

// Only this function opens the microphone.
export async function record(): Promise<Recording> {
  const directory = await mkdtemp(join(tmpdir(), "opencode-speech-"))
  let child: ReturnType<typeof Bun.spawn> | undefined
  let diagnostics: RecorderDiagnostics | undefined
  const exit = () => {
    try {
      child?.kill("SIGKILL")
    } catch {
    }
    try {
      rmSync(directory, { recursive: true, force: true })
    } catch {
    }
  }
  try {
    await chmod(directory, 0o700)
    const path = join(directory, "audio.wav")
    await (await open(path, "wx", 0o600)).close()
    child = Bun.spawn(["pw-record", "--rate=16000", "--channels=1", "--format=s16", path], {
      stdin: "ignore",
      stdout: "ignore",
      stderr: "pipe",
    })
    // Preserve PipeWire's inherited environment, but never display known credentials.
    const secrets = Object.entries(process.env)
      .filter(
        ([name, value]) => value && /key|token|secret|password|passwd|credential|authorization/i.test(name),
      )
      .map(([, value]) => value!)
    diagnostics = captureRecorderStderr(child.stderr as ReadableStream<Uint8Array>, secrets)
    process.once("exit", exit)
    const proc = child
    const lifecycle = recorderLifecycle(
      proc,
      async () => {
        try {
          await rm(directory, { recursive: true, force: true })
        } finally {
          process.removeListener("exit", exit)
        }
      },
      diagnostics,
      path,
    )
    return {
      exited: proc.exited,
      async stop() {
        await lifecycle.stop()
        const audio = new Uint8Array(await readFile(path))
        validateWav(audio)
        return audio
      },
      dispose: lifecycle.dispose,
      failure: lifecycle.failure,
    }
  } catch {
    exit()
    process.removeListener("exit", exit)
    await diagnostics?.finish()
    const snippet = diagnostics?.snippet()
    throw new SpeechError(`Unable to start pw-record.${snippet ? ` pw-record stderr: ${snippet}` : ""}`)
  }
}

export async function transcribe(
  audio: Uint8Array,
  signal: AbortSignal,
  options: SpeechOptions,
): Promise<string> {
  const key = process.env.OPENAI_API_KEY
  if (!key) {
    throw new SpeechError("Set OPENAI_API_KEY before starting OpenCode.")
  }
  validateWav(audio)
  const form = new FormData()
  form.set("file", new Blob([audio], { type: "audio/wav" }), "audio.wav")
  form.set("model", options.model)
  form.set("language", "en")
  const timeout = new AbortController()
  const timer = setTimeout(() => timeout.abort(), options.timeoutSeconds * 1000)
  try {
    const response = await fetch("https://api.openai.com/v1/audio/transcriptions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
      },
      body: form,
      signal: AbortSignal.any([signal, timeout.signal]),
    })
    if (response.status === 401) {
      throw new SpeechError("OpenAI rejected OPENAI_API_KEY (401).")
    }
    if (response.status === 429) {
      throw new SpeechError("OpenAI rate or quota limit reached (429).")
    }
    if (!response.ok) {
      throw new SpeechError(`Transcription failed (HTTP ${response.status}).`)
    }
    const result = await response.json() as { text?: unknown }
    if (!result || typeof result.text !== "string" || !result.text.trim()) {
      throw new SpeechError("No speech returned.")
    }
    return result.text.trim()
  } catch (error) {
    if (timeout.signal.aborted && !signal.aborted) {
      throw new SpeechError("Transcription timed out.")
    }
    if (error instanceof SpeechError) {
      throw error
    }
    throw new SpeechError(
      signal.aborted ? "Transcription cancelled." : "Transcription request failed. Check your connection.",
    )
  } finally {
    clearTimeout(timer)
  }
}
