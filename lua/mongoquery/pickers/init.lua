local M = {}

-- Cache for the selected backend
local backend = nil

-- Get the appropriate picker backend
local function get_backend()
  if backend then
    return backend
  end

  local config = require("mongoquery.config").get()
  local picker_type = config.picker.type

  -- Auto-detect if type is "auto"
  if picker_type == "auto" then
    -- Try fzf-lua first
    local fzf = require("mongoquery.pickers.fzf")
    if fzf.is_available() then
      backend = fzf
      return backend
    end

    -- Try Telescope second
    local telescope = require("mongoquery.pickers.telescope")
    if telescope.is_available() then
      backend = telescope
      return backend
    end

    -- Try mini.pick third
    local minipick = require("mongoquery.pickers.minipick")
    if minipick.is_available() then
      backend = minipick
      return backend
    end

    -- Fallback to vim.ui.select
    backend = require("mongoquery.pickers.fallback")
    return backend
  end

  -- Use specified backend
  if picker_type == "fzf-lua" then
    local fzf = require("mongoquery.pickers.fzf")
    if not fzf.is_available() then
      vim.notify("fzf-lua is not installed, falling back", vim.log.levels.WARN, { title = "MongoDB" })
      backend = require("mongoquery.pickers.fallback")
    else
      backend = fzf
    end
  elseif picker_type == "telescope" then
    local telescope = require("mongoquery.pickers.telescope")
    if not telescope.is_available() then
      vim.notify("Telescope is not installed, falling back", vim.log.levels.WARN, { title = "MongoDB" })
      backend = require("mongoquery.pickers.fallback")
    else
      backend = telescope
    end
  elseif picker_type == "mini.pick" then
    local minipick = require("mongoquery.pickers.minipick")
    if not minipick.is_available() then
      vim.notify("mini.pick is not installed, falling back", vim.log.levels.WARN, { title = "MongoDB" })
      backend = require("mongoquery.pickers.fallback")
    else
      backend = minipick
    end
  else
    -- Default to fallback
    backend = require("mongoquery.pickers.fallback")
  end

  return backend
end

-- Show connection picker
function M.connection_picker(connections, current_connection, on_select)
  local b = get_backend()
  return b.connection_picker(connections, current_connection, on_select)
end

-- Show query list picker
function M.query_list_picker(query_files, on_select)
  local b = get_backend()
  return b.query_list_picker(query_files, on_select)
end

-- Reset backend cache (useful for testing or when config changes)
function M.reset_backend()
  backend = nil
end

return M
