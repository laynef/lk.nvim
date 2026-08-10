local M = {}

function M.get_selection()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    local start = vim.fn.getpos("'<")
    local finish = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start[2], finish[2])
    if #lines == 0 then return "" end
    lines[#lines] = string.sub(lines[#lines], 1, finish[3])
    lines[1] = string.sub(lines[1], start[3])
    return table.concat(lines, "\n")
  end
  return ""
end

function M.get_context_lines(n)
  local row = vim.fn.line(".")
  local total = vim.fn.line("$")
  local start = math.max(1, row - n)
  local finish = math.min(total, row + math.floor(n / 2))
  return table.concat(vim.fn.getline(start, finish), "\n")
end

function M.get_file_path()
  return vim.fn.expand("%:p")
end

function M.get_relative_path()
  return vim.fn.expand("%:.")
end

function M.get_language()
  return vim.bo.filetype or "text"
end

-- Open a scratch buffer in a floating window and stream lines into it
function M.open_float(title, width_ratio, height_ratio)
  local ui = vim.api.nvim_list_uis()[1]
  local width  = math.floor((ui and ui.width  or 120) * (width_ratio  or 0.8))
  local height = math.floor((ui and ui.height or 40)  * (height_ratio or 0.6))
  local row    = math.floor(((ui and ui.height or 40)  - height) / 2)
  local col    = math.floor(((ui and ui.width  or 120) - width)  / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = width, height = height,
    row = row, col = col, style = "minimal", border = "rounded",
    title = " " .. (title or "Local Keep AI") .. " ", title_pos = "center",
  })

  -- q to close
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })

  local function append(line)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        local count = vim.api.nvim_buf_line_count(buf)
        -- Append to last line or add new line
        local last = vim.api.nvim_buf_get_lines(buf, count - 1, count, false)[1] or ""
        if last == "" then
          vim.api.nvim_buf_set_lines(buf, count - 1, count, false, { line })
        else
          vim.api.nvim_buf_set_lines(buf, count, count, false, { line })
        end
        -- Scroll to bottom
        local last_line = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(win, { last_line, 0 })
      end
    end)
  end

  return buf, win, append
end

return M
