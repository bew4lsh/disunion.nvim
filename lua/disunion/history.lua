local state = require("disunion.state")
local config = require("disunion.config")
local util = require("disunion.util")

local M = {}

local ring = {}
local head = 0
local count = 0

function M.push(bufnr, name)
  local max = config.get().history_size
  head = (head % max) + 1
  ring[head] = {
    bufnr = bufnr,
    name = name,
    timestamp = os.time(),
    filename = util.buf_name(bufnr),
  }
  if count < max then
    count = count + 1
  end
end

function M.entries()
  local max = config.get().history_size
  local result = {}
  for i = 0, count - 1 do
    local idx = ((head - 1 - i) % max) + 1
    local entry = ring[idx]
    if entry then
      local stale = not util.buf_is_valid(entry.bufnr)
      result[#result + 1] = {
        index = #result + 1,
        bufnr = entry.bufnr,
        name = entry.name,
        timestamp = entry.timestamp,
        filename = entry.filename,
        stale = stale,
      }
    end
  end
  return result
end

function M.restore(index)
  local items = M.entries()
  local entry = items[index]
  if not entry then
    util.notify("Invalid history index", vim.log.levels.WARN)
    return false
  end
  if entry.stale then
    util.notify("Buffer no longer exists: " .. entry.filename, vim.log.levels.WARN)
    return false
  end
  state.anonymous_mark = entry.bufnr
  util.notify("Restored mark: " .. entry.filename)
  return true
end

function M.reset()
  ring = {}
  head = 0
  count = 0
end

return M
