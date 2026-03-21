vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/.deps/plenary.nvim")
vim.opt.swapfile = false
vim.cmd("runtime plugin/plenary.vim")
