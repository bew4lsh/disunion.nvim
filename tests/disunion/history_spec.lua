local history = require("disunion.history")
local state = require("disunion.state")
local config = require("disunion.config")

local function make_buf(name)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name)
  return buf
end

describe("history", function()
  before_each(function()
    state.reset()
    history.reset()
    config.apply({})
  end)

  it("push + entries returns reverse-chronological order", function()
    local a = make_buf("/tmp/a.lua")
    local b = make_buf("/tmp/b.lua")
    local c = make_buf("/tmp/c.lua")
    history.push(a, nil)
    history.push(b, nil)
    history.push(c, nil)

    local e = history.entries()
    assert.equals(3, #e)
    assert.equals(c, e[1].bufnr)
    assert.equals(b, e[2].bufnr)
    assert.equals(a, e[3].bufnr)
  end)

  it("ring buffer wraps at history_size", function()
    config.apply({ history_size = 5 })
    local bufs = {}
    for i = 1, 8 do
      bufs[i] = make_buf("/tmp/ring" .. i .. ".lua")
      history.push(bufs[i], nil)
    end

    local e = history.entries()
    assert.equals(5, #e)
    assert.equals(bufs[8], e[1].bufnr)
    assert.equals(bufs[4], e[5].bufnr)
  end)

  it("entries() flags stale buffers", function()
    local buf = make_buf("/tmp/stale.lua")
    history.push(buf, nil)
    vim.api.nvim_buf_delete(buf, { force = true })

    local e = history.entries()
    assert.equals(1, #e)
    assert.is_true(e[1].stale)
  end)

  it("restore() sets state.anonymous_mark", function()
    local buf = make_buf("/tmp/restore.lua")
    history.push(buf, nil)

    local ok = history.restore(1)
    assert.is_true(ok)
    assert.equals(buf, state.anonymous_mark)
  end)

  it("restore() rejects stale entries", function()
    local buf = make_buf("/tmp/gone.lua")
    history.push(buf, nil)
    vim.api.nvim_buf_delete(buf, { force = true })

    local ok = history.restore(1)
    assert.is_false(ok)
    assert.is_nil(state.anonymous_mark)
  end)

  it("restore() rejects invalid indices", function()
    local ok = history.restore(99)
    assert.is_false(ok)
  end)

  it("reset() clears everything", function()
    local buf = make_buf("/tmp/reset.lua")
    history.push(buf, nil)
    history.reset()

    assert.equals(0, #history.entries())
  end)
end)
