// OpenCode V2 loads local plugin directories through their tui entrypoint.
// Keep cli.json pointed at this directory, not this file; file paths are skipped.
import { Plugin } from "@opencode/plugin/tui"
import type { SlotMap } from "@opencode/plugin/tui/context"
import { TextareaRenderable, type Renderable } from "@opentui/core"
import { createEffect, createSignal, onCleanup } from "solid-js"
import { SpeechController, type Target } from "../../lib/speech/controller"
import { record, transcribe } from "../../lib/speech/runtime"
import { configure, SpeechError, safeMessage, type SpeechOptions } from "../../lib/speech/config"

// V2 has no prompt ref API. Find the textarea beside this prompt's footer,
// never an arbitrary focused textarea such as a dialog or another session.
export function promptInput(anchor: Renderable | undefined): TextareaRenderable | undefined {
  if (!anchor || anchor.isDestroyed) return
  const collect = (node: Renderable): TextareaRenderable[] => {
    if (node.isDestroyed) return []
    if (node instanceof TextareaRenderable) return [node]
    return node.getChildren().flatMap(collect)
  }
  for (let node = anchor.parent; node?.parent; node = node.parent) {
    const inputs = collect(node)
    if (inputs.length) return inputs.length === 1 ? inputs[0] : undefined
  }
}

export function promptTarget(
  input: () => TextareaRenderable | undefined,
  props: SlotMap["prompt.footer.status"],
): Target {
  return {
    get route() {
      return props.sessionID ?? "home"
    },
    get available() {
      const current = input()
      // The host makes the prompt unfocusable when disabled or behind a dialog.
      return !!current && !current.isDestroyed && current.focusable && current.focused
    },
    get current() {
      return { input: input()?.plainText ?? "", mode: props.mode, parts: [] }
    },
    set(draft) {
      const current = input()
      if (!current || current.isDestroyed || !current.focusable || !current.focused) {
        throw new SpeechError("The prompt is no longer available.")
      }
      if (!draft.input.startsWith(current.plainText)) {
        throw new SpeechError("The prompt changed before the transcript could be inserted.")
      }
      const suffix = draft.input.slice(current.plainText.length)
      // Append through the editor so the host updates its draft and preserves
      // attachment extmarks. Replacing the whole buffer would lose them.
      current.clearSelection()
      current.gotoBufferEnd()
      current.insertText(suffix)
    },
  }
}

export default Plugin.define({
  id: "speech",
  setup(api) {
    let options: SpeechOptions
    try {
      options = configure(api.options)
    } catch (error) {
      api.ui.toast.show({
        title: "Speech",
        message: safeMessage(error, "Invalid speech configuration."),
        variant: "error",
      })
      return
    }
    const [status, setStatus] = createSignal("")
    const targets = new Set<Target>()
    const route = () => {
      const current = api.ui.router.current()
      if (current.type === "home") return "home"
      return current.type === "session" ? current.sessionID : `plugin:${current.id}:${current.name}`
    }
    const controller = new SpeechController({
      record: () => {
        if (!process.env.OPENAI_API_KEY) {
          throw new SpeechError("Set OPENAI_API_KEY before starting OpenCode.")
        }
        return record()
      },
      transcribe: (audio, signal) => transcribe(audio, signal, options),
      maxRecordingSeconds: options.maxRecordingSeconds,
      state: setStatus,
      target: () => [...targets].find(target => target.route === route() && target.available),
      notify: (message) => api.ui.toast.show({
        title: "Speech",
        message,
        variant: "info",
      }),
    })
    function Capture(props: SlotMap["prompt.footer.status"]) {
      let anchor: Renderable | undefined
      const target = promptTarget(() => promptInput(anchor), props)
      targets.add(target)
      onCleanup(() => targets.delete(target))
      return (
        <text ref={value => { anchor = value }}>
          {status() ? `Speech: ${status()}` : options.hints ? `Dictate ${options.keybind}` : ""}
        </text>
      )
    }
    const removeFooter = api.ui.slot({
      append: "prompt.footer.status",
      render: props => <Capture {...props} />,
    })
    const removeCommands = api.ui.slot({
      append: "app",
      render: () => {
        createEffect(() => controller.routeChanged(route()))
        api.keymap.layer(() => ({
          mode: "global",
          commands: [
            {
              id: "speech.toggle",
              title: "Toggle dictation",
              group: "Speech",
              palette: true,
              bind: options.keybind,
              run: (_input, event) => {
                // Dialogs use modal mode. Keep global palette actions available,
                // but never let their shortcut stop a recording behind a dialog.
                if (event && api.keymap.mode.current() !== "base") return
                return controller.toggle()
              },
            },
            {
              id: "speech.cancel",
              title: "Cancel dictation / discard transcript",
              group: "Speech",
              palette: true,
              run: () => controller.cancel(),
            },
            {
              id: "speech.insert",
              title: "Insert pending transcript",
              group: "Speech",
              palette: true,
              run: () => {
                api.ui.dialog.clear()
                controller.insert()
              },
            },
          ],
          bindings: ["speech.toggle"],
        }))
        return null
      },
    })
    return async () => {
      removeCommands()
      removeFooter()
      targets.clear()
      await controller.dispose()
    }
  },
})
