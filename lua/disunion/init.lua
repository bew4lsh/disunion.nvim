local M = {}

function M.setup(opts)
  require("disunion.config").apply(opts)
  require("disunion.command").register()
end

function M.mark(name)
  require("disunion.marks").set(name)
end

function M.diff()
  require("disunion.diff").diff_with_mark()
end

function M.diff_with(name)
  require("disunion.diff").diff_with_named(name)
end

function M.clear(name)
  require("disunion.marks").clear(name)
end

function M.stop()
  require("disunion.diff").stop()
end

function M.clipboard_diff()
  require("disunion.scratch").clipboard_diff()
end

function M.scratch_diff()
  require("disunion.scratch").scratch_diff()
end

function M.list_marks()
  require("disunion.picker").open_marks()
end

function M.history()
  require("disunion.picker").open_history()
end

function M.statusline()
  return require("disunion.statusline").get()
end

return M
