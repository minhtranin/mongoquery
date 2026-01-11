local M = {}

-- Always available
function M.is_available()
  return true
end

-- Connection picker using vim.ui.select
function M.connection_picker(connections, current_connection, on_select)
  local items = {}
  local name_map = {}

  for name, uri in pairs(connections) do
    local display_name = name
    if uri == current_connection then
      display_name = name .. " (v)"
    end
    table.insert(items, display_name)
    name_map[display_name] = name
  end

  if #items == 0 then
    vim.notify("No connections found. Create one with :MongoCreateConnection", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  vim.ui.select(items, {
    prompt = "Select MongoDB connection:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      local selected_name = name_map[choice]
      on_select(selected_name, connections[selected_name])
    end
  end)
end

-- Query list picker using vim.ui.select
function M.query_list_picker(query_files, on_select)
  if #query_files == 0 then
    vim.notify("No query files found in query directory", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  local items = {}
  for _, file in ipairs(query_files) do
    table.insert(items, vim.fn.fnamemodify(file, ":t"))
  end

  vim.ui.select(items, {
    prompt = "Select query file:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx then
      on_select(query_files[idx])
    end
  end)
end

return M
