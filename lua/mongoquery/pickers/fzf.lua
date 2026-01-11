local M = {}

-- Check if fzf-lua is available
function M.is_available()
  local ok = pcall(require, "fzf-lua")
  return ok
end

-- Connection picker using fzf-lua
function M.connection_picker(connections, current_connection, on_select)
  local fzf = require("fzf-lua")
  local config = require("mongoquery.config").get()

  local connection_list = {}
  for name, uri in pairs(connections) do
    if uri == current_connection then
      table.insert(connection_list, name .. " (v)")
    else
      table.insert(connection_list, name)
    end
  end

  if #connection_list == 0 then
    vim.notify("No connections found. Create one with :MongoCreateConnection", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  local opts = vim.tbl_deep_extend("force", {
    prompt = "Mongo connection> ",
    actions = {
      ["enter"] = function(selected)
        local selected_connection = selected[1]
        -- Remove the " (v)" marker if present
        if selected_connection:find(" %(v%)$") then
          selected_connection = selected_connection:gsub(" %(v%)$", "")
        end

        local uri = connections[selected_connection]
        on_select(selected_connection, uri)
      end,
    },
    winopts = {
      width = 0.30,
      height = 0.30,
      preview = {
        hidden = true,
      },
    },
  }, config.picker.opts or {})

  fzf.fzf_exec(connection_list, opts)
end

-- Query list picker using fzf-lua
function M.query_list_picker(query_files, on_select)
  local fzf = require("fzf-lua")
  local config = require("mongoquery.config").get()

  if #query_files == 0 then
    vim.notify("No query files found in query directory", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  -- Create display list with just filenames
  local display_list = {}
  for _, file in ipairs(query_files) do
    table.insert(display_list, vim.fn.fnamemodify(file, ":t"))
  end

  local opts = vim.tbl_deep_extend("force", {
    prompt = "Query list> ",
    cwd = config.query_dir,
    actions = {
      ["enter"] = function(selected)
        if selected and selected[1] then
          -- Find the full path for the selected file
          for _, file in ipairs(query_files) do
            if vim.fn.fnamemodify(file, ":t") == selected[1] then
              on_select(file)
              return
            end
          end
        end
      end,
    },
    previewer = "bat",
    winopts = {
      preview = {
        hidden = false,
        layout = "horizontal",
      },
    },
  }, config.picker.opts or {})

  fzf.fzf_exec(display_list, opts)
end

return M
