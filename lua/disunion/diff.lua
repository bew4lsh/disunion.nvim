local state = require("disunion.state")
local marks = require("disunion.marks")
local config = require("disunion.config")
local util = require("disunion.util")

local M = {}

local BASE_DIFFOPT = {
  "algorithm:patience",
  "indent-heuristic",
  "filler",
  "closeoff",
}

local function apply_diffopt()
  local current = vim.opt.diffopt:get()
  local to_add = vim.list_extend(vim.deepcopy(BASE_DIFFOPT), config.get().diffopt_extra)
  for _, opt in ipairs(to_add) do
    if not vim.tbl_contains(current, opt) then
      vim.opt.diffopt:append(opt)
    end
  end
end

local function find_window_for_buf(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

function M.open(target_bufnr, opts)
  opts = opts or {}
  local cfg = config.get()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)

  if target_bufnr == current_buf then
    util.notify("Cannot diff a buffer against itself", vim.log.levels.WARN)
    return false
  end

  apply_diffopt()

  local target_win = find_window_for_buf(target_bufnr)
  local created_win = false
  if not target_win then
    local split_dir = opts.split or cfg.split
    local cmd = split_dir == "horizontal" and "leftabove split" or "leftabove vsplit"
    vim.cmd(cmd)
    target_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(target_win, target_bufnr)
    created_win = true
  end

  vim.api.nvim_win_call(current_win, function() vim.cmd("diffthis") end)
  vim.api.nvim_win_call(target_win, function() vim.cmd("diffthis") end)

  state.diff_windows[current_win] = true
  state.diff_windows[target_win] = true
  state.diff_pair = { target_bufnr, current_buf }
  if created_win then
    state.diff_created_wins[target_win] = true
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup_id,
    pattern = tostring(current_win),
    once = true,
    callback = function()
      state.diff_windows[current_win] = nil
      state.diff_created_wins[current_win] = nil
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup_id,
    pattern = tostring(target_win),
    once = true,
    callback = function()
      state.diff_windows[target_win] = nil
      state.diff_created_wins[target_win] = nil
    end,
  })

  local focus = opts.auto_focus or cfg.auto_focus
  if focus == "marked" then
    vim.api.nvim_set_current_win(target_win)
  else
    vim.api.nvim_set_current_win(current_win)
  end

  if opts.auto_scroll_to_hunk or cfg.auto_scroll_to_hunk then
    vim.cmd("normal! ]c")
  end

  return true
end

function M.diff_with_mark()
  local bufnr = marks.get()
  if not bufnr then
    return
  end
  local ok = M.open(bufnr)
  if ok and config.get().consume_mark then
    state.anonymous_mark = nil
  end
end

function M.diff_with_named(name)
  local bufnr = marks.get(name)
  if not bufnr then
    return
  end
  M.open(bufnr)
end

function M.stop()
  local stopped = 0
  for win, _ in pairs(state.diff_windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_call(win, function() vim.cmd("diffoff") end)
      stopped = stopped + 1
    end
  end
  for win, _ in pairs(state.diff_created_wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, false)
    end
  end
  state.diff_windows = {}
  state.diff_created_wins = {}
  state.diff_pair = {}
  if stopped > 0 then
    util.notify("Diff stopped")
  else
    util.notify("No active diff", vim.log.levels.WARN)
  end
end

return M
