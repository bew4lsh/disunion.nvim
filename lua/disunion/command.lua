local config = require("disunion.config")

local M = {}

local subcommands = {
  mark = function(args) require("disunion").mark(args[1]) end,
  diff = function(args)
    if args[1] then
      require("disunion").diff_with(args[1])
    else
      require("disunion").diff()
    end
  end,
  clear = function(args) require("disunion").clear(args[1]) end,
  stop = function() require("disunion").stop() end,
  clipboard = function() require("disunion").clipboard_diff() end,
  scratch = function() require("disunion").scratch_diff() end,
  marks = function() require("disunion").list_marks() end,
  history = function() require("disunion").history() end,
}

local subcommand_names = vim.tbl_keys(subcommands)
table.sort(subcommand_names)

local function complete(_, cmdline, _)
  local parts = vim.split(cmdline, "%s+", { trimempty = true })
  if #parts <= 1 then
    return subcommand_names
  end
  local sub = parts[2]
  if sub == "clear" or sub == "diff" then
    local state = require("disunion.state")
    return vim.tbl_keys(state.named_marks)
  end
  return vim.tbl_filter(function(s)
    return s:find(sub, 1, true) == 1
  end, subcommand_names)
end

function M.register()
  vim.api.nvim_create_user_command("Disunion", function(cmd)
    local args = cmd.fargs
    local sub = table.remove(args, 1)
    if not sub then
      require("disunion").diff()
      return
    end
    local handler = subcommands[sub]
    if not handler then
      vim.notify("[disunion] Unknown subcommand: " .. sub, vim.log.levels.ERROR)
      return
    end
    handler(args)
  end, {
    nargs = "*",
    complete = complete,
    desc = "Disunion: arbitrary buffer diffing",
  })

  local keymaps = config.get().keymaps
  local map = function(key, action, desc)
    if key then
      vim.keymap.set("n", key, action, { desc = "Disunion: " .. desc })
    end
  end

  map(keymaps.mark, function() require("disunion").mark() end, "Mark buffer")
  map(keymaps.diff, function() require("disunion").diff() end, "Diff with mark")
  map(keymaps.clear, function() require("disunion").clear() end, "Clear mark")
  map(keymaps.stop, function() require("disunion").stop() end, "Stop diff")
  map(keymaps.clipboard, function() require("disunion").clipboard_diff() end, "Clipboard diff")
  map(keymaps.scratch, function() require("disunion").scratch_diff() end, "Scratch diff")
  map(keymaps.marks_list, function() require("disunion").list_marks() end, "List marks")
  map(keymaps.history, function() require("disunion").history() end, "Mark history")
end

return M
