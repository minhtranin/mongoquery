local M = {}

-- Check if Telescope is available
function M.is_available()
  local ok = pcall(require, "telescope")
  return ok
end

-- Connection picker using Telescope
function M.connection_picker(connections, current_connection, on_select)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local config = require("mongoquery.config").get()

  local connection_list = {}
  for name, uri in pairs(connections) do
    local display_name = name
    if uri == current_connection then
      display_name = name .. " (v)"
    end
    table.insert(connection_list, { name = name, display = display_name, uri = uri })
  end

  if #connection_list == 0 then
    vim.notify("No connections found. Create one with :MongoCreateConnection", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  local opts = vim.tbl_deep_extend("force", {
    prompt_title = "MongoDB Connections",
    finder = finders.new_table({
      results = connection_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          on_select(selection.value.name, selection.value.uri)
        end
      end)
      return true
    end,
  }, config.picker.opts or {})

  pickers.new(opts, opts):find()
end

-- Query list picker using Telescope
function M.query_list_picker(query_files, on_select)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local config = require("mongoquery.config").get()

  if #query_files == 0 then
    vim.notify("No query files found in query directory", vim.log.levels.WARN, {
      title = "MongoDB",
    })
    return
  end

  local opts = vim.tbl_deep_extend("force", {
    prompt_title = "MongoDB Query Files",
    finder = finders.new_table({
      results = query_files,
      entry_maker = function(entry)
        return {
          value = entry,
          display = vim.fn.fnamemodify(entry, ":t"),
          ordinal = vim.fn.fnamemodify(entry, ":t"),
          path = entry,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.vim_buffer_cat.new({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          on_select(selection.value)
        end
      end)
      return true
    end,
  }, config.picker.opts or {})

  pickers.new(opts, opts):find()
end

return M
