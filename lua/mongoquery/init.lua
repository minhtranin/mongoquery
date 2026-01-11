local M = {}

local initialized = false

-- Setup function
function M.setup(user_config)
  -- Setup configuration
  local config_module = require("mongoquery.config")
  config_module.setup(user_config)
  local config = config_module.get()

  -- Initialize persistence (create connections file if needed)
  local persistence = require("mongoquery.persistence")
  persistence.initialize()

  -- Setup keymaps if configured
  if config.keymaps then
    M.setup_keymaps(config.keymaps)
  end

  initialized = true
end

-- Setup keymaps
function M.setup_keymaps(keymaps)
  local actions = require("mongoquery.actions")

  if keymaps.connection_select then
    vim.keymap.set("n", keymaps.connection_select, actions.select_connection, {
      noremap = true,
      silent = true,
      desc = "Select MongoDB connection",
    })
  end

  if keymaps.connection_create then
    vim.keymap.set("n", keymaps.connection_create, actions.create_connection, {
      noremap = true,
      silent = true,
      desc = "Create MongoDB connection",
    })
  end

  if keymaps.connection_delete then
    vim.keymap.set("n", keymaps.connection_delete, actions.delete_connection, {
      noremap = true,
      silent = true,
      desc = "Delete MongoDB connection",
    })
  end

  if keymaps.query_run_buffer then
    vim.keymap.set("n", keymaps.query_run_buffer, function()
      actions.run_query(false)
    end, {
      noremap = true,
      silent = true,
      desc = "Run MongoDB query (buffer)",
    })
  end

  if keymaps.query_run_selection then
    vim.keymap.set("v", keymaps.query_run_selection, function()
      -- Call action directly, get_visual_text() handles active visual mode
      actions.run_query(true)
    end, {
      noremap = true,
      silent = true,
      desc = "Run MongoDB query (selection)",
    })
  end

  if keymaps.query_list then
    vim.keymap.set("n", keymaps.query_list, actions.query_list, {
      noremap = true,
      silent = true,
      desc = "List MongoDB queries",
    })
  end

  if keymaps.query_create then
    vim.keymap.set("n", keymaps.query_create, actions.create_query, {
      noremap = true,
      silent = true,
      desc = "Create MongoDB query file",
    })
  end
end

-- Ensure plugin is initialized
local function ensure_initialized()
  if not initialized then
    M.setup()
  end
end

-- Public API for commands
M.select_connection = function()
  ensure_initialized()
  require("mongoquery.actions").select_connection()
end

M.create_connection = function()
  ensure_initialized()
  require("mongoquery.actions").create_connection()
end

M.delete_connection = function()
  ensure_initialized()
  require("mongoquery.actions").delete_connection()
end

M.run_query = function(use_selection)
  ensure_initialized()
  require("mongoquery.actions").run_query(use_selection)
end

M.query_list = function()
  ensure_initialized()
  require("mongoquery.actions").query_list()
end

M.create_query = function()
  ensure_initialized()
  require("mongoquery.actions").create_query()
end

-- Development: reload plugin
M.reload = function()
  require("mongoquery.reload").reload()
end

return M
