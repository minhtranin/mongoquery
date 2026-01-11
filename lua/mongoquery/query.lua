local M = {}

-- Execute a MongoDB query
function M.run_query(query_text)
  local state = require("mongoquery.state")
  local config = require("mongoquery.config").get()
  local utils = require("mongoquery.utils")

  -- Check if mongosh is available
  if not utils.check_mongosh() then
    return
  end

  -- Load state on first use
  if not state.has_connection() then
    state.load()
  end

  -- Check if connection is selected
  local connection, connection_name = state.get_connection()
  if not connection then
    vim.notify("No MongoDB connection selected. Use :MongoSelectConnection first.", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  -- Prepare query command - use single quotes to avoid escaping issues
  local cmd = {
    config.mongosh_command,
    connection,
    config.mongosh_options,
    "--eval",
    query_text,
  }

  -- Run query with timeout
  local timeout = config.query_timeout or 30000
  local output = ""
  local success = true

  if vim.system then
    -- Neovim >= 0.10
    local result = vim.system(cmd, { text = true, timeout = timeout }):wait()
    if result.code == 124 or result.signal == 15 then
      -- Timeout or terminated
      success = false
      vim.notify("Query timeout (" .. (timeout / 1000) .. "s)", vim.log.levels.WARN, {
        title = "MongoDB",
      })
      return
    elseif result.code ~= 0 then
      success = false
      output = result.stderr or result.stdout or "Unknown error"
    else
      output = result.stdout or ""
    end
  else
    -- Fallback for older Neovim versions
    local cliquery = string.format(
      '%s %s %s --eval %s',
      config.mongosh_command,
      "'" .. connection .. "'",
      config.mongosh_options,
      "'" .. query_text .. "'"
    )
    output = vim.fn.system(cliquery)
  end

  vim.schedule(function()
    if not success then
      vim.notify("Query failed: " .. output, vim.log.levels.ERROR, {
        title = "MongoDB",
      })
      return
    end

    -- Strip ANSI color codes if present
    output = output:gsub("\27%[[0-9;]*[mK]", "")

    -- Write result to file
    local file = io.open(config.result_file, "w")
    if file then
      file:write("// Connection: " .. connection_name .. "\n")
      file:write("// " .. connection .. "\n\n")
      file:write("let result = ")
      file:write(output)
      file:close()

      -- Open result file
      vim.cmd("edit " .. vim.fn.fnameescape(config.result_file))
    else
      vim.notify("Failed to write to " .. config.result_file, vim.log.levels.ERROR, {
        title = "MongoDB",
      })
    end
  end)
end

return M
