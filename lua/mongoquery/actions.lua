local M = {}

-- Select a MongoDB connection
function M.select_connection()
  local persistence = require("mongoquery.persistence")
  local state = require("mongoquery.state")
  local pickers = require("mongoquery.pickers")

  -- Load state on first use
  if not state.has_connection() then
    state.load()
  end

  local connections = persistence.load_connections()
  local current_connection = state.get_connection()

  pickers.connection_picker(connections, current_connection, function(name, uri)
    state.set_connection(name, uri)
    vim.notify("Selected connection: " .. name, vim.log.levels.INFO, {
      id = "connection",
      title = "MongoDB",
    })
  end)
end

-- Create a new MongoDB connection
function M.create_connection()
  local persistence = require("mongoquery.persistence")

  vim.ui.input({ prompt = "Connection name: " }, function(conn_name)
    if not conn_name or conn_name == "" then
      vim.notify("Connection name cannot be empty", vim.log.levels.WARN, { title = "MongoDB" })
      return
    end

    vim.ui.input({ prompt = "Database URI: " }, function(db_uri)
      if not db_uri or db_uri == "" then
        vim.notify("Database URI cannot be empty", vim.log.levels.WARN, { title = "MongoDB" })
        return
      end

      -- Load existing connections
      local connections = persistence.load_connections()

      -- Add new connection
      connections[conn_name] = db_uri

      -- Save to file
      if persistence.save_connections(connections) then
        vim.notify("Connection '" .. conn_name .. "' added successfully!", vim.log.levels.INFO, {
          title = "MongoDB",
        })
      else
        vim.notify("Failed to save connection", vim.log.levels.ERROR, {
          title = "MongoDB",
        })
      end
    end)
  end)
end

-- Delete a MongoDB connection
function M.delete_connection()
  local persistence = require("mongoquery.persistence")
  local state = require("mongoquery.state")
  local pickers = require("mongoquery.pickers")

  -- Load state on first use
  if not state.has_connection() then
    state.load()
  end

  local connections = persistence.load_connections()
  local current_connection = state.get_connection()

  if vim.tbl_isempty(connections) then
    vim.notify("No connections to delete", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  pickers.connection_picker(connections, current_connection, function(name, uri)
    -- Remove connection from table
    connections[name] = nil

    -- Save updated connections
    if persistence.save_connections(connections) then
      vim.notify("Connection '" .. name .. "' deleted successfully!", vim.log.levels.INFO, {
        title = "MongoDB",
      })

      -- Clear state if deleted connection was the current one
      local _, current_conn_name = state.get_connection()
      if current_conn_name == name then
        state.set_connection(nil, nil)
      end
    else
      vim.notify("Failed to delete connection", vim.log.levels.ERROR, {
        title = "MongoDB",
      })
    end
  end)
end

-- Run query from buffer or selection
function M.run_query(use_selection)
  local utils = require("mongoquery.utils")
  local query_module = require("mongoquery.query")

  local query_text
  if use_selection then
    query_text = utils.get_visual_text()
  else
    query_text = utils.get_all_text()
  end

  query_module.run_query(query_text)
end

-- List and select query files
function M.query_list()
  local utils = require("mongoquery.utils")
  local pickers = require("mongoquery.pickers")

  local query_files = utils.get_query_files()

  pickers.query_list_picker(query_files, function(file)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
  end)
end

-- Create a new query file
function M.create_query()
  local config = require("mongoquery.config").get()

  vim.ui.input({ prompt = "Enter query file name: " }, function(input)
    if not input or input == "" then
      return
    end

    local filename = config.query_dir .. "/" .. input .. ".mongodb.js"

    -- Ensure directory exists
    local utils = require("mongoquery.utils")
    utils.ensure_directory(filename)

    -- Create the file if it doesn't exist
    if vim.fn.filereadable(filename) == 0 then
      vim.fn.system("touch " .. vim.fn.shellescape(filename))
    end

    -- Open the file
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
  end)
end

return M
