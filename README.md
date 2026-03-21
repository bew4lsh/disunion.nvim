# disunion.nvim

Diff any two buffers. Mark a buffer, navigate to another, diff them side by side.

Works with named marks, clipboard content, and scratch buffers. Integrates with
telescope, fzf-lua, and snacks for browsing marks and history.

## How it works

1. **Mark** a buffer — this remembers it as your diff target
2. **Navigate** to another buffer
3. **Diff** — opens a split with both buffers in diff mode

That's the core loop. Everything else builds on it:

- **Named marks** let you tag multiple buffers (`mark foo`, `mark bar`) and diff
  against any of them by name
- **Clipboard diff** pastes your clipboard into a scratch buffer and diffs it
  against the current file — useful for comparing snippets from the web or another
  editor
- **Scratch diff** opens an empty editable buffer in diff mode so you can type or
  paste into one side while seeing changes live
- **History** tracks your last N marks so you can restore one without re-navigating

Marks auto-clear when their buffer is wiped. The anonymous mark is consumed after
diffing by default (configurable). Stop diff mode at any time and you're back to
normal editing.

## Install

```lua
-- lazy.nvim
{
  "lia/disunion.nvim",
  keys = {
    { "<leader>dm", desc = "Mark buffer" },
    { "<leader>dD", desc = "Diff with mark" },
    { "<leader>dx", desc = "Clear mark" },
    { "<leader>dq", desc = "Stop diff" },
    { "<leader>dc", desc = "Clipboard diff" },
    { "<leader>ds", desc = "Scratch diff" },
    { "<leader>dM", desc = "List marks" },
    { "<leader>dh", desc = "Mark history" },
    { "<leader>dd", desc = "Pick files to diff" },
  },
  cmd = "Disunion",
  opts = {},
}
```

## Config

Shown with defaults:

```lua
require("disunion").setup({
  keymaps = {
    mark = "<leader>dm",
    diff = "<leader>dD",
    clear = "<leader>dx",
    stop = "<leader>dq",
    clipboard = "<leader>dc",
    scratch = "<leader>ds",
    marks_list = "<leader>dM",
    history = "<leader>dh",
    pick_diff = "<leader>dd",
  },
  history_size = 10,
  consume_mark = true,           -- clear anonymous mark after diffing
  auto_focus = "current",        -- "current" or "marked"
  auto_scroll_to_hunk = false,   -- jump to first hunk on diff open
  split = "vertical",            -- "vertical" or "horizontal"
  diffopt_extra = {},            -- appended to vim.opt.diffopt
  statusline = {
    mark_icon = "⊕ ",
    diff_icon = "⇔ ",
    show_name = true,            -- include mark/file names in statusline
  },
  picker = nil,                  -- nil (auto-detect), "telescope", "fzf-lua", or "snacks"
  notify = true,                 -- show notifications
})
```

Set any keymap to `false` to disable it.

## Commands

Everything is available through the `:Disunion` command with tab completion:

| Command                  | Description                                    |
| ------------------------ | ---------------------------------------------- |
| `:Disunion mark [name]`  | Mark current buffer (optionally named)         |
| `:Disunion diff [name]`  | Diff with anonymous mark, or a named mark      |
| `:Disunion clear [name]` | Clear anonymous or named mark                  |
| `:Disunion stop`         | Stop active diff                               |
| `:Disunion clipboard`    | Diff clipboard contents against current buffer |
| `:Disunion scratch`      | Open empty scratch buffer in diff mode         |
| `:Disunion marks`        | Browse named marks (picker)                    |
| `:Disunion history`      | Browse mark history (picker)                   |
| `:Disunion pick`         | Pick files to diff (picker)                    |

## Statusline

Add the diff/mark indicator to your statusline:

```lua
require("disunion").statusline()
```

Returns a string: mark icon + filename when a mark is set, diff icon + filenames
during an active diff, or `""` when idle.

**lualine example:**

```lua
lualine_x = {
  { require("disunion").statusline, cond = function() return require("disunion").statusline() ~= "" end },
}
```
