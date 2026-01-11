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
  local cliquery = string.format(
    '%s %s %s --eval %s',
    config.mongosh_command,
    "'" .. connection .. "'",
    config.mongosh_options,
    "'" .. query_text .. "'"
  )

  -- Run query
  local output = vim.fn.system(cliquery)

  vim.schedule(function()
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
