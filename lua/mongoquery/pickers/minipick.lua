local M = {}

-- Check if mini.pick is available
function M.is_available()
  local ok = pcall(require, "mini.pick")
  return ok
end

-- Connection picker using mini.pick
function M.connection_picker(connections, current_connection, on_select)
  local MiniPick = require("mini.pick")

  local items = {}
  local name_map = {}

  for name, uri in pairs(connections) do
    local display = name
    if uri == current_connection then
      display = name .. " (v)"
    end
    table.insert(items, display)
    name_map[display] = { name = name, uri = uri }
  end

  if #items == 0 then
    vim.notify("No connections found. Create one with :MongoCreateConnection", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  MiniPick.start({
    source = {
      items = items,
      name = "MongoDB Connections",
      choose = function(selected)
        if selected then
          local conn = name_map[selected]
          on_select(conn.name, conn.uri)
        end
      end,
    },
  })
end

-- Query list picker using mini.pick
function M.query_list_picker(query_files, on_select)
  local MiniPick = require("mini.pick")

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

  MiniPick.start({
    source = {
      items = items,
      name = "MongoDB Queries",
      choose = function(selected)
        if selected then
          for _, file in ipairs(query_files) do
            if vim.fn.fnamemodify(file, ":t") == selected then
              on_select(file)
              return
            end
          end
        end
      end,
      preview = function(buf_id, item)
        if item then
          for _, file in ipairs(query_files) do
            if vim.fn.fnamemodify(file, ":t") == item then
              local lines = vim.fn.readfile(file)
              vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
              vim.bo[buf_id].filetype = "javascript"
              return
            end
          end
        end
      end,
    },
  })
end

return M
