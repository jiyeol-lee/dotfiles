# Playwright CLI Commands Reference

## Core Commands

### open [url]

Opens the browser to a URL or launches browser if not running.

```bash
playwright-cli open [url]
playwright-cli open https://example.com
```

**Options:** `--browser=<chromium|firefox|webkit>` (default: chromium)

---

### close

Closes the browser.

```bash
playwright-cli close
```

---

### goto <url>

Navigates to a URL in the current browser session.

```bash
playwright-cli goto https://example.com/page
```

---

### click <ref> [button]

Performs a click on an element. Use `snapshot` first to get the element ref.

```bash
playwright-cli click "#button-id"
playwright-cli click ".menu-item" left
playwright-cli click "text=Submit" right  # right-click
```

**Options:** `left` (default), `right`, `middle` for mouse button

---

### dblclick <ref> [button]

Performs a double-click on an element.

```bash
playwright-cli dblclick "#edit-button"
```

---

### fill <ref> <text>

Fills an input field with text (clears existing content first).

```bash
playwright-cli fill "#email" "user@example.com"
playwright-cli fill "#search" ""
```

---

### type <text>

Types text character by character (like real keyboard input).

```bash
playwright-cli type "#search" "search query"
```

---

### hover <ref>

Hovers over an element.

```bash
playwright-cli hover "#dropdown-menu"
```

---

### select <ref> <value>

Selects an option in a dropdown/select element.

```bash
playwright-cli select "#country" "US"
playwright-cli select "#color" "red"
```

---

### check <ref>

Checks a checkbox or radio button.

```bash
playwright-cli check "#agree-terms"
playwright-cli check "input[name=shipping][value=express]"
```

---

### uncheck <ref>

Unchecks a checkbox.

```bash
playwright-cli uncheck "#newsletter"
```

---

### upload <file>

Uploads a file to an input element.

```bash
playwright-cli upload "/path/to/file.pdf"
```

---

### snapshot

Captures page snapshot to obtain element references.

```bash
playwright-cli snapshot
```

Outputs element tree with refs like `#id`, `.class`, `text=Label`, etc.

---

### eval <func> [ref]

Evaluates a JavaScript expression on the page or specific element.

```bash
playwright-cli eval "() => document.title"
playwright-cli eval "(el) => el.textContent" "#message"
playwright-cli eval "() => ({ width: window.innerWidth, height: window.innerHeight })"
```

---

### dialog-accept [prompt]

Accepts a dialog (alert, confirm, prompt).

```bash
playwright-cli dialog-accept
playwright-cli dialog-accept "response text"  # for prompt dialogs
```

---

### dialog-dismiss

Dismisses a dialog.

```bash
playwright-cli dialog-dismiss
```

---

### resize <w> <h>

Resizes the browser window.

```bash
playwright-cli resize 1920 1080
playwright-cli resize 375 812  # mobile
```

---

### delete-data

Deletes all browser data (cookies, localStorage, etc.).

```bash
playwright-cli delete-data
```

---

## Navigation

### go-back

Navigates to the previous page in history.

```bash
playwright-cli go-back
```

---

### go-forward

Navigates to the next page in history.

```bash
playwright-cli go-forward
```

---

### reload

Reloads the current page.

```bash
playwright-cli reload
```

---

## Keyboard Commands

### press <key>

Presses a key or key combination.

```bash
playwright-cli press "Enter"
playwright-cli press "Escape"
playwright-cli press "ArrowDown"
playwright-cli press "Control+a"
playwright-cli press "Meta+s"
playwright-cli press "Control+Shift+i"
```

**Common keys:** `Enter`, `Escape`, `Tab`, `Backspace`, `ArrowUp`, `ArrowDown`, `ArrowLeft`, `ArrowRight`, `Space`, `Control`, `Meta`, `Shift`, `Alt`

---

### keydown <key>

Presses a key down (hold).

```bash
playwright-cli keydown "Control"
```

---

### keyup <key>

Releases a key.

```bash
playwright-cli keyup "Control"
```

---

## Mouse Commands

### mousemove <x> <y>

Moves the mouse to absolute coordinates.

```bash
playwright-cli mousemove 100 200
playwright-cli mousemove 500 300
```

---

### mousedown [button]

Presses mouse button down.

```bash
playwright-cli mousedown
playwright-cli mousedown right
```

**Options:** `left` (default), `right`, `middle`

---

### mouseup [button]

Releases mouse button.

```bash
playwright-cli mouseup
```

---

### mousewheel <dx> <dy>

Scrolls the mouse wheel.

```bash
playwright-cli mousewheel 0 500    # scroll down 500
playwright-cli mousewheel 0 -300   # scroll up 300
playwright-cli mousewheel 300 0    # scroll right
```

---

## Save As

### screenshot [ref]

Takes a screenshot of the page or specific element.

```bash
playwright-cli screenshot
playwright-cli screenshot "#modal"
playwright-cli screenshot --full-page
playwright-cli screenshot --full-page --viewport-size="1280,720"
```

**Options:**

- `--full-page` - capture entire scrollable page
- `--viewport-size=<w,h>` - set viewport before screenshot
- `--timeout=<ms>` - timeout for screenshot

---

### pdf

Saves the current page as PDF.

```bash
playwright-cli pdf
playwright-cli pdf --format=A4
playwright-cli pdf --format=Letter --margin-top=20 --margin-bottom=20
```

**Options:**

- `--format=<format>` - paper format (Letter, A4, Legal, Tabloid, etc.)
- `--margin-top`, `--margin-bottom`, `--margin-left`, `--margin-right`
- `--landscape` - landscape orientation
- `--viewport-size=<w,h>` - viewport size

---

## Tab Commands

### tab-list

Lists all open tabs.

```bash
playwright-cli tab-list
```

Output: Tab indices with URLs

---

### tab-new [url]

Creates a new tab, optionally with a URL.

```bash
playwright-cli tab-new
playwright-cli tab-new https://example.com
```

---

### tab-close [index]

Closes a tab by index.

```bash
playwright-cli tab-close 1
playwright-cli tab-close 2
```

---

### tab-select <index>

Switches to a tab by index.

```bash
playwright-cli tab-select 1
```

---

## Storage Commands

### state-save [filename]

Saves browser storage (cookies, localStorage, sessionStorage) to a file.

```bash
playwright-cli state-save auth.json
playwright-cli state-save session.json
```

---

### state-load <filename>

Loads browser storage from a file.

```bash
playwright-cli state-load auth.json
```

Useful for: authenticating without re-login, restoring session state

---

### cookie-list

Lists all cookies.

```bash
playwright-cli cookie-list
playwright-cli cookie-list --domain=example.com
```

---

### cookie-get <name>

Gets a specific cookie.

```bash
playwright-cli cookie-get "session_id"
```

---

### cookie-set <name> <value>

Sets a cookie.

```bash
playwright-cli cookie-set "theme" "dark"
playwright-cli cookie-set "token" "abc123" --domain=example.com --path=/
```

**Options:** `--domain`, `--path`, `--expires`, `--httpOnly`, `--secure`, `--sameSite`

---

### cookie-delete <name>

Deletes a specific cookie.

```bash
playwright-cli cookie-delete "session_id"
```

---

### cookie-clear

Clears all cookies.

```bash
playwright-cli cookie-clear
```

---

### localstorage-list

Lists all localStorage key-value pairs.

```bash
playwright-cli localstorage-list
```

---

### localstorage-get <key>

Gets a localStorage item.

```bash
playwright-cli localstorage-get "auth_token"
```

---

### localstorage-set <key> <value>

Sets a localStorage item.

```bash
playwright-cli localstorage-set "theme" "dark"
```

---

### localstorage-delete <key>

Deletes a localStorage item.

```bash
playwright-cli localstorage-delete "theme"
```

---

### localstorage-clear

Clears all localStorage.

```bash
playwright-cli localstorage-clear
```

---

### sessionstorage-list

Lists all sessionStorage key-value pairs.

```bash
playwright-cli sessionstorage-list
```

---

### sessionstorage-get <key>

Gets a sessionStorage item.

```bash
playwright-cli sessionstorage-get "page_state"
```

---

### sessionstorage-set <key> <value>

Sets a sessionStorage item.

```bash
playwright-cli sessionstorage-set "page_state" "active"
```

---

### sessionstorage-delete <key>

Deletes a sessionStorage item.

```bash
playwright-cli sessionstorage-delete "page_state"
```

---

### sessionstorage-clear

Clears all sessionStorage.

```bash
playwright-cli sessionstorage-clear
```

---

## Network Commands

### route <pattern>

Mocks network requests matching a URL pattern.

```bash
playwright-cli route "**/api/users"
playwright-cli route "https://example.com/api/**"
```

After running, use `eval` to set the mock response or use other commands to handle the route.

---

### route-list

Lists all active network routes.

```bash
playwright-cli route-list
```

---

### unroute [pattern]

Removes network routes.

```bash
playwright-cli unroute "**/api/users"
playwright-cli unroute  # removes all routes
```

---

## DevTools Commands

### console [min-level]

Lists console messages, optionally filtered by level.

```bash
playwright-cli console
playwright-cli console log
playwright-cli console warn
playwright-cli console error
playwright-cli console debug
```

---

### network

Lists all network requests since page load.

```bash
playwright-cli network
```

---

### tracing-start

Starts trace recording.

```bash
playwright-cli tracing-start
```

---

### tracing-stop

Stops trace recording and saves the trace file.

```bash
playwright-cli tracing-stop
# Saves to trace.zip by default
```

---

### video-start

Starts video recording.

```bash
playwright-cli video-start
```

---

### video-stop

Stops video recording and saves the video file.

```bash
playwright-cli video-stop
# Saves to video.webm by default
```

---

### show

Opens DevTools panel.

```bash
playwright-cli show
```

---

### devtools-start

Starts DevTools (same as `show`).

```bash
playwright-cli devtools-start
```

---

### run-code <code>

Runs a Playwright code snippet.

```bash
playwright-cli run-code "await page.click('#btn')"
```

---

## Install Commands

### install

Initializes the workspace (installs dependencies).

```bash
playwright-cli install
```

---

### install-browser

Installs browser binaries.

```bash
playwright-cli install-browser
playwright-cli install-browser chromium
playwright-cli install-browser firefox
playwright-cli install-browser webkit
```

---

## Session Commands

### list

Lists all browser sessions.

```bash
playwright-cli list
```

---

### close-all

Closes all browser sessions gracefully.

```bash
playwright-cli close-all
```

---

### kill-all

Forcefully kills all browser sessions.

```bash
playwright-cli kill-all
```

Useful for: cleaning up stale/zombie processes

---

## Global Options

### --help [command]

Shows help for all commands or a specific command.

```bash
playwright-cli --help
playwright-cli --help click
```

---

### --version

Shows the Playwright CLI version.

```bash
playwright-cli --version
```

---

## Viewport Presets

| Device             | Viewport  | Command                           |
| ------------------ | --------- | --------------------------------- |
| Mobile S           | 320x568   | `playwright-cli resize 320 568`   |
| Mobile L           | 375x667   | `playwright-cli resize 375 667`   |
| Mobile L Landscape | 667x375   | `playwright-cli resize 667 375`   |
| Tablet             | 768x1024  | `playwright-cli resize 768 1024`  |
| Tablet Landscape   | 1024x768  | `playwright-cli resize 1024 768`  |
| Desktop            | 1280x720  | `playwright-cli resize 1280 720`  |
| Desktop L          | 1920x1080 | `playwright-cli resize 1920 1080` |

---

## Element Reference Formats

References returned by `snapshot`:

| Format         | Example          | Use Case                  |
| -------------- | ---------------- | ------------------------- |
| `#id`          | `#submit-button` | Elements with ID          |
| `.class`       | `.menu-item`     | Elements with class       |
| `text=Label`   | `text=Submit`    | Elements by text content  |
| `[attr=value]` | `[name=email]`   | Elements by attribute     |
| `role=button`  | `role=button`    | Elements by ARIA role     |
| `ref=n`        | `ref=5`          | Element by snapshot index |

Combine: `#form .field[required]`, `text=Click here #link`
