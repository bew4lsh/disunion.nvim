local diff = require("disunion.diff")
local util = require("disunion.util")

local M = {}

function M.open_as_diff(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  if not entry or not entry.path then
    return
  end
  local bufnr = vim.fn.bufadd(entry.path)
  vim.fn.bufload(bufnr)
  diff.open(bufnr)
end

function M.open_files(files, origin_bufnr)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local diff = require("disunion.diff")

  pickers.new({}, {
    prompt_title = "Disunion Pick",
    finder = finders.new_table({ results = files }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        local paths
        if #multi >= 2 then
          paths = { multi[1][1], multi[2][1] }
        else
          local entry = action_state.get_selected_entry()
          paths = entry and { entry[1] } or {}
        end
        actions.close(prompt_bufnr)
        if #paths > 0 then
          diff.diff_files(paths, origin_bufnr)
        end
      end)
      return true
    end,
  }):find()
end

function M.open_marks(marks)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Disunion Marks",
    finder = finders.new_table({
      results = marks,
      entry_maker = function(item)
        return {
          value = item,
          display = item.name .. " → " .. item.filename,
          ordinal = item.name .. " " .. item.filename,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry and util.buf_is_valid(entry.value.bufnr) then
          diff.open(entry.value.bufnr)
        end
      end)
      return true
    end,
  }):find()
end

function M.open_history(entries)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local history = require("disunion.history")

  pickers.new({}, {
    prompt_title = "Disunion History",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        local prefix = item.stale and "[stale] " or ""
        local label = item.name and (item.name .. ": ") or ""
        return {
          value = item,
          display = prefix .. label .. item.filename .. " (" .. os.date("%H:%M:%S", item.timestamp) .. ")",
          ordinal = (item.name or "") .. " " .. item.filename,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          history.restore(entry.value.index)
        end
      end)
      return true
    end,
  }):find()
end

return M
