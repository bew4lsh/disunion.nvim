local diff = require("disunion.diff")
local config = require("disunion.config")
local state = require("disunion.state")
local util = require("disunion.util")

local M = {}

local function create(opts)
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  if opts.filetype then
    vim.bo[buf].filetype = opts.filetype
  end
  if opts.lines then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.lines)
  end
  return buf
end

local function resolve_diff_target()
  if state.anonymous_mark and util.buf_is_valid(state.anonymous_mark) then
    return state.anonymous_mark
  end
  return vim.api.nvim_get_current_buf()
end

function M.clipboard_diff()
  local target = resolve_diff_target()
  local clipboard = vim.fn.getreg("+")
  if clipboard == "" then
    util.notify("Clipboard is empty", vim.log.levels.WARN)
    return
  end

  local lines = vim.split(clipboard, "\n", { plain = true })
  local ft = vim.bo[target].filetype
  local buf = create({ filetype = ft, lines = lines })

  local current_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(current_win) ~= target then
    vim.api.nvim_set_current_win(current_win)
    vim.api.nvim_win_set_buf(current_win, target)
  end

  diff.open(buf)
end

function M.scratch_diff()
  local target = resolve_diff_target()
  local ft = vim.bo[target].filetype
  local buf = create({ filetype = ft })

  local current_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(current_win) ~= target then
    vim.api.nvim_win_set_buf(current_win, target)
  end

  local ok = diff.open(buf, { auto_focus = "marked" })
  if not ok then
    return
  end

  local update, cleanup = util.debounce(function()
    if util.buf_is_valid(buf) then
      vim.cmd("diffupdate")
    end
  end, 200)

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = state.augroup_id,
    buffer = buf,
    callback = update,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.augroup_id,
    buffer = buf,
    once = true,
    callback = cleanup,
  })
end

return M
