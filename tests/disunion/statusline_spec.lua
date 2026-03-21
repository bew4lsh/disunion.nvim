local statusline = require("disunion.statusline")
local state = require("disunion.state")
local history = require("disunion.history")
local config = require("disunion.config")
local util = require("disunion.util")

local function make_buf(name)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name)
  return buf
end

describe("statusline", function()
  before_each(function()
    state.reset()
    history.reset()
    config.apply({})
    vim.cmd("only!")
  end)

  it("returns empty string with no state", function()
    assert.equals("", statusline.get())
  end)

  it("returns mark_icon + filename when anonymous mark set", function()
    local buf = make_buf("/tmp/status_anon.lua")
    state.anonymous_mark = buf

    local result = statusline.get()
    assert.equals("⊕ status_anon.lua", result)
  end)

  it("returns mark_icon + name:filename for named mark with show_name=true", function()
    local buf = make_buf("/tmp/status_named.lua")
    state.named_marks.test = buf

    local result = statusline.get()
    assert.equals("⊕ test:status_named.lua", result)
  end)

  it("returns diff_icon + filenames when diff windows tracked", function()
    local a = make_buf("/tmp/sl_a.lua")
    local b = make_buf("/tmp/sl_b.lua")
    vim.api.nvim_set_current_buf(a)

    local diff = require("disunion.diff")
    diff.open(b)

    local result = statusline.get()
    assert.truthy(result:find("⇔ "))
    assert.truthy(result:find("sl_a.lua"))
    assert.truthy(result:find("sl_b.lua"))
  end)

  it("respects show_name=false for named marks", function()
    config.apply({ statusline = { show_name = false } })
    local buf = make_buf("/tmp/status_noname.lua")
    state.named_marks.hidden = buf

    local result = statusline.get()
    assert.equals("⊕ status_noname.lua", result)
  end)

  it("respects show_name=false for diff", function()
    config.apply({ statusline = { show_name = false } })
    local a = make_buf("/tmp/sl_c.lua")
    local b = make_buf("/tmp/sl_d.lua")
    vim.api.nvim_set_current_buf(a)

    local diff = require("disunion.diff")
    diff.open(b)

    local result = statusline.get()
    assert.equals("⇔ diff", result)
  end)
end)
