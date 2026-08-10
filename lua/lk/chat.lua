local M = {}
local client = require("lk.client")
local util   = require("lk.util")

local state = {
  buf = nil, win = nil, input_buf = nil, input_win = nil,
  history = {},
}

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local ui = vim.api.nvim_list_uis()[1]
  local w = math.floor((ui and ui.width  or 120) * 0.75)
  local h = math.floor((ui and ui.height or 40)  * 0.7)
  local r = math.floor(((ui and ui.height or 40) - h - 4) / 2)
  local c = math.floor(((ui and ui.width  or 120) - w) / 2)

  -- Chat history window
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)
  state.win = vim.api.nvim_open_win(state.buf, false, {
    relative = "editor", width = w, height = h, row = r, col = c,
    style = "minimal", border = "rounded",
    title = " Local Keep AI Chat ", title_pos = "center",
  })

  -- Input window below
  state.input_buf = vim.api.nvim_create_buf(false, true)
  state.input_win = vim.api.nvim_open_win(state.input_buf, true, {
    relative = "editor", width = w, height = 3, row = r + h + 1, col = c,
    style = "minimal", border = "rounded",
    title = " Message (Enter to send, q to close) ", title_pos = "center",
  })

  -- Enter to send
  vim.api.nvim_buf_set_keymap(state.input_buf, "n", "<CR>", "", {
    noremap = true, silent = true,
    callback = function() M._send() end,
  })
  vim.api.nvim_buf_set_keymap(state.input_buf, "i", "<C-CR>", "", {
    noremap = true, silent = true,
    callback = function() M._send() end,
  })
  vim.api.nvim_buf_set_keymap(state.input_buf, "n", "q", "", {
    noremap = true, silent = true,
    callback = function() M.close() end,
  })

  vim.cmd("startinsert")
  M._render()
end

function M._send()
  local lines = vim.api.nvim_buf_get_lines(state.input_buf, 0, -1, false)
  local text = table.concat(lines, "\n"):match("^%s*(.-)%s*$")
  if text == "" then return end

  vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, {""})
  table.insert(state.history, { role = "user", content = text })
  M._render()

  local model = client.read_default_model()
  local prompt = text
  -- Include last few turns for context
  if #state.history > 1 then
    local ctx = {}
    for i = math.max(1, #state.history - 6), #state.history - 1 do
      table.insert(ctx, state.history[i].role .. ": " .. state.history[i].content)
    end
    prompt = table.concat(ctx, "\n") .. "\nuser: " .. text
  end

  local reply_lines = {}
  table.insert(state.history, { role = "assistant", content = "" })

  client.run_async(
    { "ask", "--model", model, "--raw", prompt },
    vim.fn.getcwd(),
    function(line)
      table.insert(reply_lines, line)
      state.history[#state.history].content = table.concat(reply_lines, "\n")
      M._render()
    end,
    function(_) M._render() end
  )
end

function M._render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  vim.api.nvim_buf_set_option(state.buf, "modifiable", true)
  local lines = {}
  for _, msg in ipairs(state.history) do
    local prefix = msg.role == "user" and "You: " or "Local Keep AI: "
    for i, line in ipairs(vim.split(msg.content, "\n")) do
      table.insert(lines, (i == 1 and prefix or "      ") .. line)
    end
    table.insert(lines, "")
  end
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)
  -- Scroll to bottom
  local count = vim.api.nvim_buf_line_count(state.buf)
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_cursor(state.win, { count, 0 })
  end
end

function M.close()
  if state.win       and vim.api.nvim_win_is_valid(state.win)       then vim.api.nvim_win_close(state.win, true) end
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then vim.api.nvim_win_close(state.input_win, true) end
  state.win = nil; state.input_win = nil
end

return M
