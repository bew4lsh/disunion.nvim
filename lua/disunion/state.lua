local M = {}

M.anonymous_mark = nil
M.named_marks = {}
M.diff_windows = {}
M.augroup_id = vim.api.nvim_create_augroup("Disunion", { clear = true })

function M.reset()
  M.anonymous_mark = nil
  M.named_marks = {}
  M.diff_windows = {}
  vim.api.nvim_create_augroup("Disunion", { clear = true })
end

return M
