local M = {}

-- Get all text from current buffer
function M.get_all_text()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")
  -- Replace single quotes with double quotes for JSON compatibility
  text = string.gsub(text, "'", '"')
  return text
end

-- Get text from visual selection
function M.get_visual_text()
  -- Try to get current visual selection if in visual mode
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then  -- \22 is <C-v>
    -- Get visual selection boundaries while still in visual mode
    local start_pos = vim.fn.getpos('v')
    local end_pos = vim.fn.getpos('.')

    local start_line = math.min(start_pos[2], end_pos[2]) - 1
    local end_line = math.max(start_pos[2], end_pos[2])

    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local text = table.concat(lines, "\n")
    text = string.gsub(text, "'", '"')
    return text
  else
    -- Fall back to marks (after visual mode has exited)
    local start_line = vim.fn.line("'<") - 1
    local end_line = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local text = table.concat(lines, "\n")
    text = string.gsub(text, "'", '"')
    return text
  end
end

-- Ensure directory exists
function M.ensure_directory(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

-- Check if mongosh is available
function M.check_mongosh()
  local config = require("mongoquery.config").get()
  if vim.fn.executable(config.mongosh_command) == 0 then
    vim.notify(
      string.format("'%s' is not installed or not in PATH", config.mongosh_command),
      vim.log.levels.ERROR,
      { title = "MongoDB" }
    )
    return false
  end
  return true
end

-- Get query files from query directory
function M.get_query_files()
  local config = require("mongoquery.config").get()
  local query_dir = config.query_dir

  -- Ensure directory exists
  if vim.fn.isdirectory(query_dir) == 0 then
    vim.fn.mkdir(query_dir, "p")
    return {}
  end

  -- Use vim.fn.glob to find .mongodb.js files
  local pattern = query_dir .. "/*.mongodb.js"
  local files = vim.fn.glob(pattern, false, true)

  -- Sort by modification time (newest first)
  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  return files
end

return M
