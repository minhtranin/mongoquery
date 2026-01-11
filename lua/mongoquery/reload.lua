-- Reload helper for development
local M = {}

function M.reload()
  -- Clear all mongoquery modules from cache
  for k in pairs(package.loaded) do
    if k:match("^mongoquery") then
      package.loaded[k] = nil
    end
  end

  -- Re-setup the plugin with existing config
  require("mongoquery").setup()

  print("✓ mongoquery.nvim reloaded!")
end

return M
