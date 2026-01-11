local M = {}

-- Default configuration
M.defaults = {
  connections_file = vim.fn.stdpath("config") .. "/mongo-connections.json",
  query_dir = vim.fn.stdpath("data") .. "/mongoquery/queries",
  result_file = "/tmp/mongoquery-result.js",

  picker = {
    type = "auto", -- "auto" | "fzf-lua" | "telescope" | "mini.pick" | "vim.ui.select"
    opts = {},   -- Backend-specific options
  },

  keymaps = {
    connection_select = "<leader>qa",
    connection_create = "<leader>qn",
    connection_delete = "<leader>qd",
    query_run_buffer = "<leader>qm",
    query_run_selection = "<leader>qp",
    query_list = "<leader>ql",
    query_create = "<leader>qc",
  },

  mongosh_command = "mongosh",
  mongosh_options = "--quiet",
}

-- Current configuration (will be populated by setup)
M.options = {}

-- Setup function to merge user config with defaults
function M.setup(user_config)
  user_config = user_config or {}

  -- Deep merge defaults with user config
  M.options = vim.tbl_deep_extend("force", M.defaults, user_config)

  -- Expand paths
  M.options.connections_file = vim.fn.expand(M.options.connections_file)
  M.options.query_dir = vim.fn.expand(M.options.query_dir)
  M.options.result_file = vim.fn.expand(M.options.result_file)

  return M.options
end

-- Get current config
function M.get()
  if vim.tbl_isempty(M.options) then
    return M.setup()
  end
  return M.options
end

return M
