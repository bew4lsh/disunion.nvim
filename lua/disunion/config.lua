local M = {}

local defaults = {
  keymaps = {
    mark = "<leader>dm",
    diff = "<leader>dD",
    clear = "<leader>dx",
    stop = "<leader>dq",
    clipboard = "<leader>dc",
    scratch = "<leader>ds",
    marks_list = "<leader>dM",
    history = "<leader>dh",
    pick_diff = "<leader>dd",
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
