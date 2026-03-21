local config = require("disunion.config")
local util = require("disunion.util")

local M = {}

local backends = {
  telescope = "disunion.picker.telescope",
  ["fzf-lua"] = "disunion.picker.fzf",
  snacks = "disunion.picker.snacks",
}

local function detect_backend()
  local configured = config.get().picker
  if configured then
    return configured
  end
  if pcall(require, "telescope") then return "telescope" end
  if pcall(require, "fzf-lua") then return "fzf-lua" end
  if pcall(require, "snacks") then return "snacks" end
  return nil
end

local function get_backend()
  local name = detect_backend()
  if not name then
    util.notify("No picker backend found. Install telescope, fzf-lua, or snacks.", vim.log.levels.ERROR)
    return nil
  end
  local mod_path = backends[name]
  if not mod_path then
    util.notify("Unknown picker backend: " .. name, vim.log.levels.ERROR)
    return nil
  end
  return require(mod_path)
end

function M.open_marks()
  local marks = require("disunion.marks").list()
  if #marks == 0 then
    util.notify("No named marks set", vim.log.levels.WARN)
    return
  end
  local backend = get_backend()
  if not backend then return end
  backend.open_marks(marks)
end

function M.open_history()
  local entries = require("disunion.history").entries()
  if #entries == 0 then
    util.notify("No mark history", vim.log.levels.WARN)
    return
  end
  local backend = get_backend()
  if not backend then return end
  backend.open_history(entries)
end

return M
