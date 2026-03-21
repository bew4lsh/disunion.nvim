local scratch = require("disunion.scratch")
local diff = require("disunion.diff")
local state = require("disunion.state")
local history = require("disunion.history")
local marks = require("disunion.marks")
local config = require("disunion.config")

local function make_buf(name, ft)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name)
  if ft then
    vim.bo[buf].filetype = ft
  end
  return buf
end

local function set_current_buf(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

describe("scratch", function()
  before_each(function()
    state.reset()
    history.reset()
    config.apply({})
    vim.cmd("only!")
    vim.fn.setreg("+", "")
  end)

  it("clipboard_diff() creates scratch with clipboard content and opens diff", function()
    local buf = make_buf("/tmp/scratch_cb.lua")
    set_current_buf(buf)
    vim.fn.setreg("+", "line1\nline2\nline3")

    scratch.clipboard_diff()

    assert.equals(2, #vim.api.nvim_list_wins())
    local tracked = 0
    for _ in pairs(state.diff_windows) do
      tracked = tracked + 1
    end
    assert.equals(2, tracked)
  end)

  it("clipboard_diff() warns on empty clipboard", function()
    local buf = make_buf("/tmp/scratch_empty.lua")
    set_current_buf(buf)
    vim.fn.setreg("+", "")

    assert.has_no.errors(function()
      scratch.clipboard_diff()
    end)
    assert.equals(1, #vim.api.nvim_list_wins())
  end)

  it("scratch_diff() creates empty scratch buffer in diff mode", function()
    local buf = make_buf("/tmp/scratch_s.lua")
    set_current_buf(buf)

    scratch.scratch_diff()

    assert.equals(2, #vim.api.nvim_list_wins())
  end)

  it("clipboard_diff() inherits filetype from target buffer", function()
    local buf = make_buf("/tmp/scratch_ft.py", "python")
    set_current_buf(buf)
    vim.fn.setreg("+", "print('hello')")

    scratch.clipboard_diff()

    local wins = vim.api.nvim_list_wins()
    local found_python = false
    for _, win in ipairs(wins) do
      local b = vim.api.nvim_win_get_buf(win)
      if vim.bo[b].filetype == "python" and b ~= buf then
        found_python = true
      end
    end
    assert.is_true(found_python)
  end)

  it("falls back to current buffer when no mark set", function()
    local buf = make_buf("/tmp/scratch_fb.lua")
    set_current_buf(buf)
    vim.fn.setreg("+", "content")

    scratch.clipboard_diff()
    assert.equals(2, #vim.api.nvim_list_wins())
  end)
end)
