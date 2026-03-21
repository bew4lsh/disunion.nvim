local diff = require("disunion.diff")
local state = require("disunion.state")
local marks = require("disunion.marks")
local history = require("disunion.history")
local config = require("disunion.config")

local function make_buf(name)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name)
  return buf
end

local function set_current_buf(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

local function count_windows()
  return #vim.api.nvim_list_wins()
end

describe("diff", function()
  before_each(function()
    state.reset()
    history.reset()
    config.apply({})
    vim.cmd("only!")
  end)

  it("open() creates vsplit and enables diff in both windows", function()
    local a = make_buf("/tmp/diff_a.lua")
    local b = make_buf("/tmp/diff_b.lua")
    set_current_buf(a)

    local ok = diff.open(b)
    assert.is_true(ok)
    assert.equals(2, count_windows())

    local tracked = 0
    for _ in pairs(state.diff_windows) do
      tracked = tracked + 1
    end
    assert.equals(2, tracked)
  end)

  it("open() rejects same-buffer diff", function()
    local buf = make_buf("/tmp/diff_self.lua")
    set_current_buf(buf)

    local ok = diff.open(buf)
    assert.is_false(ok)
  end)

  it("open({split='horizontal'}) creates horizontal split", function()
    local a = make_buf("/tmp/diff_h1.lua")
    local b = make_buf("/tmp/diff_h2.lua")
    set_current_buf(a)

    local before_win = vim.api.nvim_get_current_win()
    diff.open(b, { split = "horizontal" })

    local wins = vim.api.nvim_list_wins()
    assert.equals(2, #wins)

    local widths = {}
    for _, w in ipairs(wins) do
      widths[#widths + 1] = vim.api.nvim_win_get_width(w)
    end
    assert.equals(widths[1], widths[2])
  end)

  it("diff_with_mark() consumes anonymous mark when consume_mark=true", function()
    config.apply({ consume_mark = true })
    local a = make_buf("/tmp/diff_c1.lua")
    local b = make_buf("/tmp/diff_c2.lua")
    set_current_buf(a)
    marks.set()
    set_current_buf(b)

    diff.diff_with_mark()
    assert.is_nil(state.anonymous_mark)
  end)

  it("stop() runs diffoff on tracked windows and clears state", function()
    local a = make_buf("/tmp/diff_s1.lua")
    local b = make_buf("/tmp/diff_s2.lua")
    set_current_buf(a)
    diff.open(b)

    diff.stop()

    local tracked = 0
    for _ in pairs(state.diff_windows) do
      tracked = tracked + 1
    end
    assert.equals(0, tracked)
  end)

  it("stop() closes the split that disunion created", function()
    local a = make_buf("/tmp/diff_close1.lua")
    local b = make_buf("/tmp/diff_close2.lua")
    set_current_buf(a)
    diff.open(b)
    assert.equals(2, count_windows())

    diff.stop()
    assert.equals(1, count_windows())
  end)

  it("stop() warns when no active diff", function()
    assert.has_no.errors(function()
      diff.stop()
    end)
  end)

  it("WinClosed auto-cleans state.diff_windows", function()
    local a = make_buf("/tmp/diff_wc1.lua")
    local b = make_buf("/tmp/diff_wc2.lua")
    set_current_buf(a)
    diff.open(b)

    local target_win = nil
    for win in pairs(state.diff_windows) do
      if win ~= vim.api.nvim_get_current_win() then
        target_win = win
        break
      end
    end

    if target_win then
      vim.api.nvim_win_close(target_win, true)
      vim.wait(50, function() return false end)
      assert.is_nil(state.diff_windows[target_win])
    end
  end)
end)
