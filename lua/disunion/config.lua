local M = {}

local defaults = {
  keymaps = {
    mark = "<leader>Dm",
    diff = "<leader>DD",
    clear = "<leader>Dx",
    stop = "<leader>Dq",
    clipboard = "<leader>Dc",
    scratch = "<leader>Ds",
    marks_list = "<leader>DM",
    history = "<leader>Dh",
    pick_diff = "<leader>Dd",
  },
  history_size = 10,
  consume_mark = true,
  auto_focus = "current",
  auto_scroll_to_hunk = false,
  split = "vertical",
  diffopt_extra = {},
  statusline = {
    mark_icon = "⊕ ",
    diff_icon = "⇔ ",
    show_name = true,
  },
  picker = nil,
  notify = true,
}

local config = vim.deepcopy(defaults)

function M.apply(user_opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_opts or {})
end

function M.get()
  return config
end

return M
