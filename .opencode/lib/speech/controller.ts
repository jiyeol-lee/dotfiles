import type { Recording } from "./runtime"
import { safeMessage, SpeechError } from "./config"

export type Draft = {
  input: string
  mode?: "normal" | "shell"
  parts: unknown[]
}
export type Target = {
  route: string
  current: Draft
  available?: boolean
  set(value: Draft): void
}
type Dependencies = {
  record(): Promise<Recording>
  transcribe(audio: Uint8Array, signal: AbortSignal): Promise<string>
  target(): Target | undefined
  notify(message: string): void
  state?(value: string): void
  maxRecordingSeconds?: number
}
type Job = {
  abort: AbortController
  startup: Promise<Recording>
  recording?: Recording
  stopping: boolean
  timer?: ReturnType<typeof setTimeout>
  origin: Target
  route: string
  cleanup?: Promise<void>
  moved?: boolean
}

export class SpeechController {
  private job?: Job
  private pending?: string
  private disposed = false
  constructor(private deps: Dependencies) {}

  private state(value: string) {
    if (!this.disposed) {
      this.deps.state?.(value)
    }
  }

  private notify(message: string) {
    if (!this.disposed) {
      this.deps.notify(message)
    }
  }

  async toggle() {
    if (this.disposed) {
      return
    }
    if (this.job) {
      if (this.job.abort.signal.aborted) {
        return
      }
      if (!this.job.recording) {
        await this.cancel()
      } else if (!this.job.stopping) {
        await this.finish(this.job)
      }
      return
    }
    if (this.pending) {
      this.notify("Insert or cancel the pending transcript first.")
      return
    }
    const origin = this.deps.target()
    if (!origin || origin.available === false || origin.current.mode === "shell") {
      this.notify("Dictation requires an enabled normal prompt.")
      return
    }
    const job: Job = {
      abort: new AbortController(),
      stopping: false,
      origin,
      route: origin.route,
      startup: Promise.resolve().then(() => {
        if (job.abort.signal.aborted) {
          throw new SpeechError("Recording cancelled.")
        }
        return this.deps.record()
      }),
    }
    this.job = job
    this.state("Starting microphone")
    try {
      const recording = await job.startup
      job.recording = recording
      // Attach both handlers even when cancellation happened during startup.
      void recording.exited.then(
        () => this.recorderExited(job),
        () => this.recorderExited(job),
      )
      if (job.abort.signal.aborted) {
        await this.release(job)
        return
      }
      this.state("Recording")
      this.notify("Recording. Toggle dictation to stop; Speech: Cancel to discard.")
      job.timer = setTimeout(() => void this.finish(job), (this.deps.maxRecordingSeconds ?? 120) * 1000)
    } catch (error) {
      if (!job.abort.signal.aborted) {
        this.notify(safeMessage(error, "Unable to start recording. Check pw-record."))
      }
      await this.release(job)
    }
  }

  private async recorderExited(job: Job) {
    if (this.job !== job || job.stopping || job.abort.signal.aborted) {
      return
    }
    job.stopping = true
    clearTimeout(job.timer)
    const fallback = "Recorder exited unexpectedly. Recording discarded."
    let message = fallback
    let timer: ReturnType<typeof setTimeout> | undefined
    try {
      if (job.recording?.failure) {
        message = safeMessage(
          await Promise.race([
            Promise.resolve().then(() => job.recording!.failure!()),
            new Promise<SpeechError>(resolve => {
              timer = setTimeout(() => resolve(new SpeechError(fallback)), 200)
            }),
          ]),
          fallback,
        )
      }
    } catch {
    } finally {
      clearTimeout(timer)
    }
    if (this.job !== job || job.abort.signal.aborted) {
      return
    }
    this.notify(message)
    await this.cancel()
  }

  private release(job: Job): Promise<void> {
    return job.cleanup ??= (async () => {
      clearTimeout(job.timer)
      let recording: Recording
      try {
        recording = await job.startup
      } catch {
        return
      }
      try {
        await recording.dispose()
      } catch {
        this.notify("Recording cleanup failed. Check private temporary files.")
      }
    })().finally(() => {
      if (this.job === job) {
        this.job = undefined
        this.state(this.pending ? "Transcript pending" : "")
      }
    })
  }

  private async finish(job: Job) {
    if (job.stopping || !job.recording || job.abort.signal.aborted) {
      return
    }
    job.stopping = true
    clearTimeout(job.timer)
    try {
      const audio = await job.recording.stop()
      if (job.abort.signal.aborted) {
        return
      }
      this.state("Transcribing")
      const text = await this.deps.transcribe(audio, job.abort.signal)
      if (this.job !== job || job.abort.signal.aborted || this.disposed) {
        return
      }
      this.pending = text
      const current = this.deps.target()
      if (!job.moved && current === job.origin && current.route === job.route) {
        this.insert()
      } else {
        this.notify("Transcript pending. Use Speech: Insert pending transcript in the desired prompt.")
      }
    } catch (error) {
      if (!job.abort.signal.aborted) {
        this.notify(safeMessage(error, "Transcription failed. Check your connection and recording."))
      }
    } finally {
      await this.release(job)
    }
  }

  routeChanged(route: string) {
    if (this.job && route !== this.job.route) {
      this.job.moved = true
    }
  }

  insert() {
    if (this.disposed || !this.pending) {
      return
    }
    const target = this.deps.target()
    if (!target || target.available === false || target.current.mode === "shell") {
      this.notify("Transcript retained. Select an enabled normal prompt to insert it.")
      return
    }
    const draft = target.current
    target.set({
      ...draft,
      input: draft.input + (draft.input && !/\s$/.test(draft.input) ? " " : "") + this.pending,
    })
    this.pending = undefined
    this.state("")
    this.notify("Transcript inserted. Review and submit manually.")
  }

  async cancel() {
    this.pending = undefined
    const job = this.job
    if (!job) {
      this.state("")
      return
    }
    job.abort.abort()
    this.state("Stopping microphone")
    await this.release(job)
  }

  async dispose() {
    this.disposed = true
    await this.cancel()
  }
}
