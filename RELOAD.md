# How to Reload mongoquery.nvim with New Features

## Quick Reload (Current Session)

In your running Neovim session:

```vim
" 1. Clear all mongoquery modules
:lua for k in pairs(package.loaded) do if k:match("^mongoquery") then package.loaded[k] = nil end end

" 2. Reload the plugin
:lua require('mongoquery').setup({ result_file = '~/workspace/backup/query/result.js' })

" 3. Done! New features are loaded
```

## Or Just Restart Neovim

The easiest way:
1. Close Neovim
2. Reopen Neovim
3. Everything loads fresh automatically

## Test Auto-Completion

### If you have nvim-cmp installed:

1. Select a connection: `:MongoSelectConnection` or `<leader>qa`
2. Create/open a query file: `:MongoCreateQuery` or `<leader>qc`
3. Type `db.` and completions should appear automatically!

### If you don't have nvim-cmp:

1. Select a connection: `:MongoSelectConnection` or `<leader>qa`
2. Create/open a query file: `:MongoCreateQuery` or `<leader>qc`
3. Type `db.` then press `<C-x><C-o>` (omni-completion)
4. Collections popup appears!

## What's New

✅ Auto-completion for MongoDB collections
✅ Works with nvim-cmp, blink.cmp, or built-in omnifunc
✅ Smart caching (5 minutes)
✅ Auto-refreshes when switching connections
✅ Result files now use `.js` extension with JavaScript comments

## Lazy.nvim Config (Optional)

Add this helper command to your config for easy reloading during development:

```lua
{
  dir = "/home/tcm/workspace/personal/mongoquery",
  name = "mongoquery.nvim",
  -- ... other config ...
  config = function()
    require("mongoquery").setup({
      result_file = "~/workspace/backup/query/result.js",
    })

    -- Quick reload command
    vim.api.nvim_create_user_command("MongoReload", function()
      for k in pairs(package.loaded) do
        if k:match("^mongoquery") then
          package.loaded[k] = nil
        end
      end
      require("mongoquery").setup({
        result_file = "~/workspace/backup/query/result.js",
      })
      print("✓ Reloaded mongoquery.nvim")
    end, {})
  end,
}
```

Then just type `:MongoReload` after making changes!
