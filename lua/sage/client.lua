local M = {}
local config = {}

function M.setup(cfg)
  config = cfg or {}
end

function M.find_binary()
  local candidates = {
    config.binary,
    "sage",
    vim.fn.expand("~/.local/bin/sage"),
    vim.fn.expand("~/.pyenv/shims/sage"),
    "/opt/homebrew/bin/sage",
    "/usr/local/bin/sage",
  }
  for _, p in ipairs(candidates) do
    if p and p ~= "" and vim.fn.executable(p) == 1 then
      return p
    end
  end
  error("sage binary not found. Install: pip install sage-ai-cli && sage login")
end

function M.read_default_model()
  if config.model and config.model ~= "" then return config.model end
  local path = vim.fn.expand("~/.sage/config.json")
  local f = io.open(path, "r")
  if not f then return "cloud:qwen3-coder" end
  local ok, data = pcall(vim.fn.json_decode, f:read("*a"))
  f:close()
  if ok and data and data.default_model then return data.default_model end
  return "cloud:qwen3-coder"
end

-- Non-blocking subprocess. on_chunk(line) called per stdout line; on_done(exit_code) at end.
function M.run_async(args, cwd, on_chunk, on_done)
  local binary = M.find_binary()
  local full_args = vim.list_extend({ binary }, args)
  local env = vim.fn.environ()
  env["NO_COLOR"] = "1"
  env["TERM"] = "dumb"
  local job_id = vim.fn.jobstart(full_args, {
    cwd = cwd or vim.fn.getcwd(),
    env = env,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then on_chunk(line) end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then on_chunk("[err] " .. line) end
        end
      end
    end,
    on_exit = function(_, code)
      if on_done then on_done(code) end
    end,
    stdout_buffered = false,
  })
  return job_id
end

-- Blocking subprocess for quick commands (model list, status).
function M.run_sync(args, cwd)
  local binary = M.find_binary()
  local full_args = vim.list_extend({ binary }, args)
  local result = {}
  local job_id = vim.fn.jobstart(full_args, {
    cwd = cwd or vim.fn.getcwd(),
    stdout_buffered = true,
    on_stdout = function(_, data) result = data end,
  })
  vim.fn.jobwait({ job_id }, 15000)
  return table.concat(result, "\n")
end

return M
