import assert from "node:assert/strict"
import test from "node:test"
import { captureRecorderStderr, recorderLifecycle, validateWav } from "./runtime"

const filename = "/tmp/opencode-speech-test/audio.wav"

function capture(text: string, end: "close" | "open" | "error" = "close") {
  return captureRecorderStderr(new ReadableStream<Uint8Array>({
    start(controller) {
      controller.enqueue(new TextEncoder().encode(text))
      if (end === "close") controller.close()
      if (end === "error") controller.error(new Error("broken pipe"))
    },
  }), [])
}

function recorder(diagnostics: ReturnType<typeof capture>, code = 1, signal: NodeJS.Signals | null = null) {
  let resolve!: (code: number) => void
  const signals: Array<string | number | undefined> = []
  const proc = {
    exitCode: null as number | null,
    signalCode: null as NodeJS.Signals | null,
    exited: new Promise<number>(done => { resolve = done }),
    kill(sent?: number | NodeJS.Signals) {
      signals.push(sent)
      proc.exitCode = code
      proc.signalCode = signal
      resolve(code)
    },
  }
  return { proc, signals, lifecycle: recorderLifecycle(proc, async () => {}, diagnostics, filename) }
}

for (const [version, stderr] of [["1.6.9", ""], ["whitespace", " \t\r\n"], ["1.6.8", `${filename}\n`]]) {
  test(`intentional exit 1 accepts complete ${version} stderr`, async () => {
    const { lifecycle, signals } = recorder(capture(stderr))
    await lifecycle.stop()
    assert.deepEqual(signals, ["SIGINT"])
  })
}

for (const [label, stderr, end] of [
  ["error text", "failed to connect", "close"],
  ["filename and error", `${filename}\nwrite failed`, "close"],
  ["different filename", "/other/audio.wav", "close"],
  ["incomplete empty stream", "", "open"],
  ["incomplete filename", filename, "open"],
  ["truncated whitespace", " ".repeat(8193), "close"],
  ["truncated filename output", filename + " ".repeat(8192), "close"],
  ["failed stream", "", "error"],
] as const) {
  test(`intentional exit 1 rejects ${label}`, async () => {
    const diagnostics = capture(stderr, end)
    const { lifecycle } = recorder(diagnostics)
    await assert.rejects(lifecycle.stop(), /Recorder failed/)
    assert.equal(diagnostics.hasOnlyExpectedOutput(filename), false)
  })
}

test("empty diagnostics must finish before being accepted", async () => {
  const diagnostics = capture("")
  assert.equal(diagnostics.hasOnlyExpectedOutput(filename), false)
  await diagnostics.finish()
  assert.equal(diagnostics.hasOnlyExpectedOutput(filename), true)
})

test("exit 1 before an intentional stop is rejected", async () => {
  const { proc, lifecycle } = recorder(capture(""))
  proc.kill()
  await assert.rejects(lifecycle.stop(), /Recorder exited unexpectedly/)
})

test("empty stderr does not excuse other exit codes or forced signals", async () => {
  for (const [code, signal] of [[2, null], [1, "SIGKILL"], [1, "SIGTERM"]] as const) {
    const { lifecycle } = recorder(capture(""), code, signal)
    await assert.rejects(lifecycle.stop(), /Recorder failed/)
  }
})

test("a stop timeout remains a failure even when SIGKILL reports exit 1", async () => {
  const { proc, lifecycle, signals } = recorder(capture(""))
  const kill = proc.kill
  proc.kill = signal => {
    if (signal === "SIGKILL") kill(signal)
  }
  await assert.rejects(lifecycle.stop(), /Recorder stop timed out/)
  assert.deepEqual(signals, ["SIGKILL"])
})

test("accepted stop output still requires a complete WAV", async () => {
  const audio = new Uint8Array(46)
  const view = new DataView(audio.buffer)
  const tag = (offset: number, text: string) => audio.set(new TextEncoder().encode(text), offset)
  tag(0, "RIFF")
  view.setUint32(4, 38, true)
  tag(8, "WAVE")
  tag(12, "fmt ")
  view.setUint32(16, 16, true)
  view.setUint16(20, 1, true)
  view.setUint16(22, 1, true)
  view.setUint32(24, 16000, true)
  view.setUint32(28, 32000, true)
  view.setUint16(32, 2, true)
  view.setUint16(34, 16, true)
  tag(36, "data")
  view.setUint32(40, 2, true)

  await recorder(capture("")).lifecycle.stop()
  assert.doesNotThrow(() => validateWav(audio))
  assert.throws(() => validateWav(new Uint8Array()), /Recording is empty/)
  view.setUint32(4, 0, true)
  assert.throws(() => validateWav(audio), /Recording is not a complete/)
})
