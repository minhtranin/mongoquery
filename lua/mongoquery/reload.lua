-- Reload helper for development
local M = {}

function M.reload()
  -- Save user config before clearing cache
  local config = require("mongoquery.config")
  local saved_user_config = vim.deepcopy(config.user_config)

  -- Clear all mongoquery modules from cache
  for k in pairs(package.loaded) do
    if k:match("^mongoquery") then
      package.loaded[k] = nil
    end
  end

  -- Re-setup the plugin with saved user config
  require("mongoquery").setup(saved_user_config)

  print("✓ mongoquery.nvim reloaded!")
end

return M
