local diff = require("disunion.diff")
local util = require("disunion.util")

local M = {}

function M.open_as_diff(selected)
  local path = selected[1]
  if not path then return end
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  diff.open(bufnr)
end

function M.open_files(files, origin_bufnr)
  local fzf = require("fzf-lua")
  local diff = require("disunion.diff")
  fzf.fzf_exec(files, {
    prompt = "Disunion Pick> ",
    fzf_opts = { ["--multi"] = 2 },
    actions = {
      ["default"] = function(selected)
        if #selected > 0 then
          diff.diff_files(selected, origin_bufnr)
        end
      end,
    },
  })
end

function M.open_marks(marks)
  local fzf = require("fzf-lua")
  local items = {}
  local lookup = {}
  for _, item in ipairs(marks) do
    local display = item.name .. " → " .. item.filename
    items[#items + 1] = display
    lookup[display] = item
  end
  fzf.fzf_exec(items, {
    prompt = "Disunion Marks> ",
    actions = {
      ["default"] = function(selected)
        local entry = lookup[selected[1]]
        if entry and util.buf_is_valid(entry.bufnr) then
          diff.open(entry.bufnr)
        end
      end,
    },
  })
end

function M.open_history(entries)
  local fzf = require("fzf-lua")
  local history = require("disunion.history")
  local items = {}
  local lookup = {}
  for _, item in ipairs(entries) do
    local prefix = item.stale and "[stale] " or ""
    local label = item.name and (item.name .. ": ") or ""
    local display = prefix .. label .. item.filename .. " (" .. os.date("%H:%M:%S", item.timestamp) .. ")"
    items[#items + 1] = display
    lookup[display] = item
  end
  fzf.fzf_exec(items, {
    prompt = "Disunion History> ",
    actions = {
      ["default"] = function(selected)
        local entry = lookup[selected[1]]
        if entry then
          history.restore(entry.index)
        end
      end,
    },
  })
end

return M
