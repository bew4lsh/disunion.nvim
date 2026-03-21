local marks = require("disunion.marks")
local state = require("disunion.state")
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

describe("marks", function()
  before_each(function()
    state.reset()
    history.reset()
    config.apply({})
  end)

  it("set() stores anonymous mark", function()
    local buf = make_buf("/tmp/anon.lua")
    set_current_buf(buf)
    marks.set()
    assert.equals(buf, state.anonymous_mark)
  end)

  it("set(name) stores named mark", function()
    local buf = make_buf("/tmp/named.lua")
    set_current_buf(buf)
    marks.set("alpha")
    assert.equals(buf, state.named_marks.alpha)
  end)

  it("set() pushes to history", function()
    local buf = make_buf("/tmp/hist.lua")
    set_current_buf(buf)
    marks.set()
    assert.equals(1, #history.entries())
  end)

  it("clear() removes anonymous mark", function()
    local buf = make_buf("/tmp/clr.lua")
    set_current_buf(buf)
    marks.set()
    marks.clear()
    assert.is_nil(state.anonymous_mark)
  end)

  it("clear(name) removes named mark", function()
    local buf = make_buf("/tmp/clrn.lua")
    set_current_buf(buf)
    marks.set("beta")
    marks.clear("beta")
    assert.is_nil(state.named_marks.beta)
  end)

  it("clear() on empty mark warns without error", function()
    assert.has_no.errors(function()
      marks.clear()
    end)
  end)

  it("get() returns bufnr for anonymous mark", function()
    local buf = make_buf("/tmp/getanon.lua")
    set_current_buf(buf)
    marks.set()
    assert.equals(buf, marks.get())
  end)

  it("get(name) returns bufnr for named mark", function()
    local buf = make_buf("/tmp/getnamed.lua")
    set_current_buf(buf)
    marks.set("gamma")
    assert.equals(buf, marks.get("gamma"))
  end)

  it("get() returns nil on missing mark", function()
    assert.is_nil(marks.get())
  end)

  it("get() auto-clears when buffer wiped", function()
    local buf = make_buf("/tmp/wipe.lua")
    set_current_buf(buf)
    marks.set()

    local other = make_buf("/tmp/other.lua")
    set_current_buf(other)
    vim.api.nvim_buf_delete(buf, { force = true })

    assert.is_nil(marks.get())
    assert.is_nil(state.anonymous_mark)
  end)

  it("list() returns sorted named marks", function()
    local b1 = make_buf("/tmp/zz.lua")
    local b2 = make_buf("/tmp/aa.lua")

    set_current_buf(b1)
    marks.set("zeta")
    set_current_buf(b2)
    marks.set("alpha")

    local result = marks.list()
    assert.equals(2, #result)
    assert.equals("alpha", result[1].name)
    assert.equals("zeta", result[2].name)
  end)

  it("list() excludes wiped buffers", function()
    local buf = make_buf("/tmp/wiped.lua")
    set_current_buf(buf)
    marks.set("gone")

    local other = make_buf("/tmp/keep.lua")
    set_current_buf(other)
    vim.api.nvim_buf_delete(buf, { force = true })

    local result = marks.list()
    assert.equals(0, #result)
  end)

  it("BufWipeout autocmd auto-clears anonymous mark", function()
    local buf = make_buf("/tmp/autoclr.lua")
    set_current_buf(buf)
    marks.set()

    local other = make_buf("/tmp/stay.lua")
    set_current_buf(other)
    vim.api.nvim_buf_delete(buf, { force = true })

    assert.is_nil(state.anonymous_mark)
  end)

  it("BufWipeout autocmd auto-clears named mark", function()
    local buf = make_buf("/tmp/autoname.lua")
    set_current_buf(buf)
    marks.set("doomed")

    local other = make_buf("/tmp/safe.lua")
    set_current_buf(other)
    vim.api.nvim_buf_delete(buf, { force = true })

    assert.is_nil(state.named_marks.doomed)
  end)
end)
