local state = require("disunion.state")
local history = require("disunion.history")
local util = require("disunion.util")

local M = {}

local wipeout_autocmds = {}

local function register_wipeout(bufnr, name)
  local key = name or ""
  if wipeout_autocmds[key] then
    pcall(vim.api.nvim_del_autocmd, wipeout_autocmds[key])
  end
  wipeout_autocmds[key] = vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.augroup_id,
    buffer = bufnr,
    once = true,
    callback = function()
      wipeout_autocmds[key] = nil
      if name then
        if state.named_marks[name] == bufnr then
          state.named_marks[name] = nil
          util.notify("Named mark '" .. name .. "' cleared (buffer wiped)", vim.log.levels.WARN)
        end
      else
        if state.anonymous_mark == bufnr then
          state.anonymous_mark = nil
          util.notify("Mark cleared (buffer wiped)", vim.log.levels.WARN)
        end
      end
    end,
  })
end

function M.set(name)
  local bufnr = vim.api.nvim_get_current_buf()
  if name then
    state.named_marks[name] = bufnr
    register_wipeout(bufnr, name)
    history.push(bufnr, name)
    util.notify("Named mark '" .. name .. "' set: " .. util.buf_name(bufnr))
  else
    state.anonymous_mark = bufnr
    register_wipeout(bufnr, nil)
    history.push(bufnr, nil)
    util.notify("Mark set: " .. util.buf_name(bufnr))
  end
end

function M.clear(name)
  if name then
    if not state.named_marks[name] then
      util.notify("No named mark '" .. name .. "'", vim.log.levels.WARN)
      return
    end
    state.named_marks[name] = nil
    if wipeout_autocmds[name] then
      pcall(vim.api.nvim_del_autocmd, wipeout_autocmds[name])
      wipeout_autocmds[name] = nil
    end
    util.notify("Cleared named mark '" .. name .. "'")
  else
    if not state.anonymous_mark then
      util.notify("No mark set", vim.log.levels.WARN)
      return
    end
    state.anonymous_mark = nil
    if wipeout_autocmds[""] then
      pcall(vim.api.nvim_del_autocmd, wipeout_autocmds[""])
      wipeout_autocmds[""] = nil
    end
    util.notify("Mark cleared")
  end
end

function M.get(name)
  local bufnr
  if name then
    bufnr = state.named_marks[name]
    if not bufnr then
      util.notify("No named mark '" .. name .. "'", vim.log.levels.WARN)
      return nil
    end
  else
    bufnr = state.anonymous_mark
    if not bufnr then
      util.notify("No mark set", vim.log.levels.WARN)
      return nil
    end
  end
  if not util.buf_is_valid(bufnr) then
    util.notify("Marked buffer no longer exists", vim.log.levels.WARN)
    M.clear(name)
    return nil
  end
  return bufnr
end

function M.list()
  local result = {}
  for name, bufnr in pairs(state.named_marks) do
    if util.buf_is_valid(bufnr) then
      result[#result + 1] = {
        name = name,
        bufnr = bufnr,
        filename = util.buf_name(bufnr),
      }
    end
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

return M
