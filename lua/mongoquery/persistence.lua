local M = {}

-- Load connections from JSON file
function M.load_connections()
  local config = require("mongoquery.config").get()
  local file = io.open(config.connections_file, "r")

  if not file then
    return {}
  end

  local content = file:read("*all")
  file:close()

  if content == "" then
    return {}
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify(
      "Failed to parse connections file: " .. config.connections_file,
      vim.log.levels.ERROR,
      { title = "MongoDB" }
    )
    return {}
  end

  if data and data.connections then
    return data.connections
  end

  return {}
end

-- Save connections to JSON file
function M.save_connections(connections)
  local config = require("mongoquery.config").get()
  local data = { connections = connections }

  local ok, content = pcall(vim.json.encode, data)
  if not ok then
    vim.notify("Failed to encode connections data", vim.log.levels.ERROR, { title = "MongoDB" })
    return false
  end

  -- Create directory if it doesn't exist
  local dir = vim.fn.fnamemodify(config.connections_file, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  local file = io.open(config.connections_file, "w")
  if not file then
    vim.notify("Failed to open connections file for writing", vim.log.levels.ERROR, { title = "MongoDB" })
    return false
  end

  file:write(content)
  file:close()
  return true
end

-- Initialize connections file if it doesn't exist
function M.initialize()
  local config = require("mongoquery.config").get()
  local file = io.open(config.connections_file, "r")

  if file then
    file:close()
    return -- File exists, don't initialize
  end

  -- Create with empty connections
  local default_connections = {}
  M.save_connections(default_connections)
end

return M
