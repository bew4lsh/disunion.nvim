local M = {}

M.anonymous_mark = nil
M.named_marks = {}
M.diff_windows = {}
M.diff_created_wins = {}
M.augroup_id = vim.api.nvim_create_augroup("Disunion", { clear = true })

function M.reset()
  M.anonymous_mark = nil
  M.named_marks = {}
  M.diff_windows = {}
  M.diff_created_wins = {}
  vim.api.nvim_create_augroup("Disunion", { clear = true })
end

return M
