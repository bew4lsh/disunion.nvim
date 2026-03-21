local state = require("disunion.state")
local config = require("disunion.config")
local util = require("disunion.util")

local M = {}

function M.get()
  local cfg = config.get().statusline

  local has_diff = false
  for win, _ in pairs(state.diff_windows) do
    if vim.api.nvim_win_is_valid(win) then
      has_diff = true
      break
    end
  end

  if has_diff then
    if not cfg.show_name then
      return cfg.diff_icon .. "diff"
    end
    local names = {}
    for win, _ in pairs(state.diff_windows) do
      if vim.api.nvim_win_is_valid(win) then
        local bufnr = vim.api.nvim_win_get_buf(win)
        names[#names + 1] = util.buf_name(bufnr)
      end
    end
    return cfg.diff_icon .. table.concat(names, " ↔ ")
  end

  if state.anonymous_mark and util.buf_is_valid(state.anonymous_mark) then
    local name = util.buf_name(state.anonymous_mark)
    return cfg.mark_icon .. name
  end

  for mark_name, bufnr in pairs(state.named_marks) do
    if util.buf_is_valid(bufnr) then
      local display = cfg.show_name and (mark_name .. ":" .. util.buf_name(bufnr)) or util.buf_name(bufnr)
      return cfg.mark_icon .. display
    end
  end

  return ""
end

return M
