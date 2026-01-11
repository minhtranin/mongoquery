# mongoquery.nvim

A lightweight MongoDB query development tool for Neovim with support for multiple fuzzy finder backends.

## Features

- 🚀 Execute MongoDB queries directly from Neovim buffers
- 🔍 **Auto-detects** UI backend: fzf-lua, Telescope, mini.pick, or vim.ui.select
- 🔌 Create, select, and delete MongoDB connections
- 📁 Save and organize query files
- ⚡ Fast query execution with minimal overhead
- ✂️ Visual mode support for running partial queries
- 💾 Persistent connection state across sessions

## Requirements

- Neovim >= 0.8.0
- MongoDB Shell (`mongosh`) installed and in PATH
- Optional (recommended): [fzf-lua](https://github.com/ibhagwan/fzf-lua), [Telescope](https://github.com/nvim-telescope/telescope.nvim), or [mini.pick](https://github.com/echasnovski/mini.pick)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

Add this to your lazy.nvim configuration:

```lua
{
  "minhtranin/mongoquery",
  dependencies = {
    -- Optional: Choose your preferred picker (auto-detects if available)
    "ibhagwan/fzf-lua",
    -- OR "nvim-telescope/telescope.nvim",
    -- OR "echasnovski/mini.pick",
  },
  cmd = {
    "MongoSelectConnection",
    "MongoCreateConnection",
    "MongoDeleteConnection",
    "MongoRunQuery",
    "MongoQueryList",
    "MongoCreateQuery",
    "MongoReload",
  },
  keys = {
    { "<leader>qa", "<cmd>MongoSelectConnection<cr>", desc = "MongoDB: Select connection" },
    { "<leader>qn", "<cmd>MongoCreateConnection<cr>", desc = "MongoDB: Create connection" },
    { "<leader>qd", "<cmd>MongoDeleteConnection<cr>", desc = "MongoDB: Delete connection" },
    { "<leader>qm", "<cmd>MongoRunQuery<cr>", desc = "MongoDB: Run query (buffer)" },
    { "<leader>qp", "<cmd>MongoRunQuery<cr>", mode = "v", desc = "MongoDB: Run query (selection)" },
    { "<leader>ql", "<cmd>MongoQueryList<cr>", desc = "MongoDB: List queries" },
    { "<leader>qc", "<cmd>MongoCreateQuery<cr>", desc = "MongoDB: Create query file" },
  },
  config = function()
    require("mongoquery").setup({
      -- Optional: Customize query directory (default: ~/.local/share/nvim/mongoquery/queries)
      -- query_dir = "~/workspace/backup/query",
      -- query_dir = "~/Documents/mongodb-queries",

      -- Optional: Customize result file location (default: /tmp/mongoquery-result.js)
      -- result_file = "/tmp/my-mongo-result.js",

      -- Optional: Force specific picker
      -- picker = { type = "auto" }, -- "auto" | "fzf-lua" | "telescope" | "mini.pick" | "vim.ui.select"
    })
  end,
}
```

This configuration enables **lazy loading** - the plugin only loads when you use a command or keymap, ensuring zero impact on Neovim startup time.

## Quick Start

1. **Install the plugin** using lazy.nvim (see above)
2. **Create a connection**:
   ```vim
   :MongoCreateConnection
   ```
   Or press `<leader>qn`, then enter:
   - Connection name: `Local Dev`
   - Database URI: `mongodb://localhost:27017/mydb`

3. **Create a query file**:
   ```vim
   :MongoCreateQuery
   ```
   Or press `<leader>qc`, enter `test-query`, then write:
   ```javascript
   db.users.find({})
   ```

4. **Run the query**:
   - Press `<leader>qm` to run the entire buffer
   - Or select specific lines in visual mode and press `<leader>qp`

5. **View results** - Opens automatically in a new buffer!

## Configuration

### Default Configuration

```lua
require("mongoquery").setup({
  -- Path to connections JSON file
  connections_file = vim.fn.stdpath("config") .. "/mongo-connections.json",

  -- Directory for query files (default: ~/.local/share/nvim/mongoquery/queries)
  query_dir = vim.fn.stdpath("data") .. "/mongoquery/queries",

  -- Path to result output file (stored in /tmp for automatic cleanup)
  result_file = "/tmp/mongoquery-result.js",

  -- Picker configuration
  picker = {
    type = "auto", -- "auto" | "fzf-lua" | "telescope" | "mini.pick" | "vim.ui.select"
    opts = {},     -- Backend-specific options
  },

  -- Keymaps (set to false to disable all keymaps)
  keymaps = {
    connection_select = "<leader>qa",
    connection_create = "<leader>qn",
    connection_delete = "<leader>qd",
    query_run_buffer = "<leader>qm",
    query_run_selection = "<leader>qp",
    query_list = "<leader>ql",
    query_create = "<leader>qc",
  },

  -- MongoDB shell configuration
  mongosh_command = "mongosh",
  mongosh_options = "--quiet",
})
```

### Custom Configuration Example

```lua
require("mongoquery").setup({
  -- Use a custom query directory
  query_dir = "~/projects/mongodb-queries",
  result_file = "/tmp/my-mongo-result.js",

  -- Force use of Telescope
  picker = {
    type = "telescope",
    opts = {
      layout_strategy = "horizontal",
    },
  },

  -- Disable keymaps and set your own
  keymaps = false,
})

-- Set custom keymaps
vim.keymap.set("n", "<leader>ms", require("mongoquery").select_connection)
vim.keymap.set("n", "<leader>mr", require("mongoquery").run_query)
```

### Picker Backend Priority

When `picker.type = "auto"` (default), the plugin detects backends in this order:
1. **fzf-lua** (fastest, recommended)
2. **Telescope** (feature-rich)
3. **mini.pick** (minimal)
4. **vim.ui.select** (fallback, always available)

The detected backend is cached on first use for optimal performance.

## Usage

### Connection Management

#### Create a Connection

```vim
:MongoCreateConnection
```
Or press `<leader>qn`

Enter the connection name and MongoDB URI when prompted.

#### Select a Connection

```vim
:MongoSelectConnection
```
Or press `<leader>qa`

Choose from your saved connections. The current connection is marked with `(v)`.

#### Delete a Connection

```vim
:MongoDeleteConnection
```
Or press `<leader>qd`

Select a connection to delete. If you delete the active connection, you'll need to select a new one.

### Query Management

#### Create a Query File

```vim
:MongoCreateQuery
```
Or press `<leader>qc`

Enter a filename (without extension). Files are saved with `.mongodb.js` extension for syntax highlighting.

#### List Query Files

```vim
:MongoQueryList
```
Or press `<leader>ql`

Browse and open existing query files with preview support (if using fzf-lua or Telescope).

#### Run a Query

**Run entire buffer:**
```vim
:MongoRunQuery
```
Or press `<leader>qm`

**Run visual selection:**
1. Select lines in visual mode
2. Press `<leader>qp`

Results open automatically in a new buffer with connection info at the top.

## Example Queries

```javascript
// List all databases
db.adminCommand({ listDatabases: 1 })

// Find documents
db.users.find({ age: { $gt: 25 } }).limit(10)

// Aggregate pipeline
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } }
])

// Update documents
db.products.updateMany(
  { category: "electronics" },
  { $set: { onSale: true } }
)
```

## Commands Reference

| Command | Keymap | Description |
|---------|--------|-------------|
| `:MongoSelectConnection` | `<leader>qa` | Select a MongoDB connection |
| `:MongoCreateConnection` | `<leader>qn` | Create a new connection |
| `:MongoDeleteConnection` | `<leader>qd` | Delete a saved connection |
| `:MongoRunQuery` | `<leader>qm` / `<leader>qp` | Run query (buffer or selection) |
| `:MongoQueryList` | `<leader>ql` | List saved query files |
| `:MongoCreateQuery` | `<leader>qc` | Create a new query file |
| `:MongoReload` | - | Reload plugin (development) |

## Health Check

Check the plugin status:

```vim
:checkhealth mongoquery
```

This will verify:
- MongoDB Shell installation
- Connections file status
- Query directory status
- Picker backend availability
- Current connection state

## Performance

mongoquery.nvim is designed to have **zero impact** on Neovim startup time:

- **Lazy loading**: Plugin loads only when you use a command or keymap
- **Minimal code**: ~1200 lines of Lua, no external dependencies
- **Cached backend**: UI backend detection happens once and is cached
- **Lazy state loading**: Connection state loads on first use, not at startup
- **No autocommands**: No background processes or file watchers

Typical startup overhead: **0ms** (when lazy loaded properly)

## File Structure

```
~/.config/nvim/
└── mongo-connections.json              # Saved connections (version controlled)

~/.local/share/nvim/
├── mongoquery-state.json               # Last selected connection (per-machine)
└── mongoquery/
    └── queries/
        └── *.mongodb.js                # Your query files

/tmp/
└── mongoquery-result.js                # Query results (auto-cleaned on reboot)
```

### Connections File Format

```json
{
  "connections": {
    "Local Dev": "mongodb://localhost:27017/mydb",
    "Production": "mongodb+srv://user:pass@cluster.mongodb.net/prod?authSource=admin"
  }
}
```

The connections file is stored in your Neovim config directory, making it easy to version control and share across machines. The state file (last selected connection) is stored separately in the data directory to remain machine-specific.

## Tips & Best Practices

1. **File Extension**: Use `.mongodb.js` extension for syntax highlighting - the plugin auto-adds this

2. **Single Quotes**: Write queries with single quotes - they're automatically converted to double quotes for JSON compatibility

3. **Visual Mode**: Select specific queries in visual mode (`<leader>qp`) to run only what you need

4. **Query Organization**: Create subdirectories in your query directory for better organization

5. **Connection Strings**: Supports both standard (`mongodb://`) and SRV (`mongodb+srv://`) formats

6. **Development Workflow**: Use `:MongoReload` during plugin development to reload changes

7. **Version Control**: Add `mongo-connections.json` to your dotfiles repo to share connections across machines

8. **Persistent State**: Last selected connection persists across Neovim sessions automatically

## Troubleshooting

### "mongosh is not installed"

Install MongoDB Shell: https://www.mongodb.com/docs/mongodb-shell/install/

### "No picker available"

Install either fzf-lua or Telescope:
- fzf-lua: https://github.com/ibhagwan/fzf-lua
- Telescope: https://github.com/nvim-telescope/telescope.nvim

### Query execution hangs

Check your connection string and ensure MongoDB server is accessible.

### Results not showing

Verify the result file path exists and is writable. Check `:checkhealth mongoquery`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Credits

Inspired by the need for a lightweight MongoDB query tool integrated into the Neovim workflow.
