local M = {}

function M.check()
  local health = vim.health or require("health")

  health.start("mongoquery.nvim")

  -- Check mongosh availability
  local config = require("mongoquery.config").get()
  if vim.fn.executable(config.mongosh_command) == 1 then
    health.ok(string.format("'%s' is installed", config.mongosh_command))
  else
    health.error(
      string.format("'%s' is not installed or not in PATH", config.mongosh_command),
      { "Install MongoDB Shell: https://www.mongodb.com/docs/mongodb-shell/" }
    )
  end

  -- Check connections file
  local connections_file = config.connections_file
  if vim.fn.filereadable(connections_file) == 1 then
    health.ok("Connections file exists: " .. connections_file)

    -- Try to load connections
    local persistence = require("mongoquery.persistence")
    local connections = persistence.load_connections()
    local count = 0
    for _ in pairs(connections) do
      count = count + 1
    end
    health.info(string.format("Found %d saved connection(s)", count))
  else
    health.warn(
      "Connections file not found: " .. connections_file,
      { "File will be created when you add your first connection" }
    )
  end

  -- Check query directory
  local query_dir = config.query_dir
  if vim.fn.isdirectory(query_dir) == 1 then
    health.ok("Query directory exists: " .. query_dir)

    -- Count query files
    local utils = require("mongoquery.utils")
    local query_files = utils.get_query_files()
    health.info(string.format("Found %d query file(s)", #query_files))
  else
    health.warn(
      "Query directory not found: " .. query_dir,
      { "Directory will be created when needed" }
    )
  end

  -- Check picker backend
  local picker_type = config.picker.type
  health.info("Configured picker: " .. picker_type)

  -- Detect which picker is being used
  local fzf_ok = require("mongoquery.pickers.fzf").is_available()
  local telescope_ok = require("mongoquery.pickers.telescope").is_available()
  local minipick_ok = require("mongoquery.pickers.minipick").is_available()

  if fzf_ok then
    health.ok("Using fzf-lua")
  elseif telescope_ok then
    health.ok("Using Telescope")
  elseif minipick_ok then
    health.ok("Using mini.pick")
  else
    health.ok("Using vim.ui.select (fallback)")
  end

  -- Check current connection state
  local state = require("mongoquery.state")
  if state.has_connection() then
    local _, conn_name = state.get_connection()
    health.info("Current connection: " .. conn_name)
    health.info("Last connection persisted to: " .. vim.fn.stdpath("data") .. "/mongoquery-state.json")
  else
    health.info("No connection selected")
  end
end

return M
