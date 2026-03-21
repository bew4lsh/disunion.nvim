local config = require("disunion.config")

local M = {}

function M.notify(msg, level)
  if not config.get().notify then
    return
  end
  vim.notify("[disunion] " .. msg, level or vim.log.levels.INFO)
end

function M.buf_is_valid(bufnr)
  return bufnr ~= nil
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
end

function M.buf_name(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return "[No Name]"
  end
  return vim.fn.fnamemodify(name, ":t")
end

function M.debounce(fn, ms)
  local timer = vim.uv.new_timer()
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, vim.schedule_wrap(function()
      fn(unpack(args))
    end))
  end, function()
    timer:stop()
    timer:close()
  end
end

return M
