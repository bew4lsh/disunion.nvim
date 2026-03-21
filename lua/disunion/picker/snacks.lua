local diff = require("disunion.diff")
local util = require("disunion.util")

local M = {}

function M.open_as_diff(picker)
  local item = picker:current()
  picker:close()
  if not item or not item.file then return end
  local bufnr = vim.fn.bufadd(item.file)
  vim.fn.bufload(bufnr)
  diff.open(bufnr)
end

function M.open_marks(marks)
  local snacks = require("snacks")
  local items = {}
  for _, item in ipairs(marks) do
    items[#items + 1] = {
      text = item.name .. " → " .. item.filename,
      item = item,
    }
  end
  snacks.picker({
    title = "Disunion Marks",
    items = items,
    format = function(item) return { { item.text } } end,
    confirm = function(picker, item)
      picker:close()
      if item and util.buf_is_valid(item.item.bufnr) then
        diff.open(item.item.bufnr)
      end
    end,
  })
end

function M.open_history(entries)
  local snacks = require("snacks")
  local history = require("disunion.history")
  local items = {}
  for _, item in ipairs(entries) do
    local prefix = item.stale and "[stale] " or ""
    local label = item.name and (item.name .. ": ") or ""
    items[#items + 1] = {
      text = prefix .. label .. item.filename .. " (" .. os.date("%H:%M:%S", item.timestamp) .. ")",
      item = item,
    }
  end
  snacks.picker({
    title = "Disunion History",
    items = items,
    format = function(item) return { { item.text } } end,
    confirm = function(picker, item)
      picker:close()
      if item then
        history.restore(item.item.index)
      end
    end,
  })
end

return M
