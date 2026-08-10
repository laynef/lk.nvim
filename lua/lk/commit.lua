local M = {}
local client = require("lk.client")
local util   = require("lk.util")

function M.generate()
  local cwd = vim.fn.getcwd()
  -- Get staged diff
  local diff_job = vim.fn.jobstart({ "git", "diff", "--staged" }, {
    cwd = cwd,
    stdout_buffered = true,
    on_stdout = function(_, data)
      local diff = table.concat(data, "\n"):match("^%s*(.-)%s*$")
      if not diff or diff == "" then
        vim.notify("No staged changes. Run: git add <files>", vim.log.levels.WARN)
        return
      end
      local prompt = "Write a git commit message (conventional commits format, max 72-char subject line) for:\n\n" .. diff:sub(1, 4000)
      local model = client.read_default_model()
      local _, _, append = util.open_float("Local Keep AI: Commit Message")

      client.run_async(
        { "ask", "--model", model, "--raw", prompt },
        cwd,
        function(line) append(line) end,
        function(_)
          append("")
          append("─── Copy message above and use: git commit -m '<message>' ───")
        end
      )
    end,
  })
  vim.fn.jobwait({ diff_job }, 5000)
end

return M
