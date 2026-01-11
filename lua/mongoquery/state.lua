local M = {}

-- Current state
M.current_connection = nil
M.current_connection_name = nil

-- Get state file path
local function get_state_file()
  local config = require("mongoquery.config").get()
  return vim.fn.stdpath("data") .. "/mongoquery-state.json"
end

-- Load last selected connection
function M.load()
  local state_file = get_state_file()
  local file = io.open(state_file, "r")

  if not file then
    return nil, nil
  end

  local content = file:read("*all")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if ok and data then
    M.current_connection = data.uri
    M.current_connection_name = data.name
  end

  return M.current_connection, M.current_connection_name
end

-- Save current connection
function M.save()
  local state_file = get_state_file()

  if not M.current_connection then
    -- Clear the state file if no connection
    local file = io.open(state_file, "w")
    if file then
      file:write("{}")
      file:close()
    end
    return
  end

  local data = {
    name = M.current_connection_name,
    uri = M.current_connection,
  }

  local content = vim.json.encode(data)
  local file = io.open(state_file, "w")
  if file then
    file:write(content)
    file:close()
  end
end

-- Set current connection
function M.set_connection(name, uri)
  M.current_connection_name = name
  M.current_connection = uri
  M.save() -- Auto-save when connection changes
end

-- Get current connection
function M.get_connection()
  return M.current_connection, M.current_connection_name
end

-- Check if a connection is selected
function M.has_connection()
  return M.current_connection ~= nil
end

-- Clear current connection
function M.clear_connection()
  M.current_connection = nil
  M.current_connection_name = nil
end

return M
