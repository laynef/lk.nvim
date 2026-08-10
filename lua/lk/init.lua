local M = {}

M.config = {
  model        = "",          -- "" = read from ~/.sage/config.json
  context_lines = 50,
  binary       = "",          -- "" = auto-discover
  keymaps = {
    explain  = "<leader>se",
    refactor = "<leader>sr",
    tests    = "<leader>st",
    fix      = "<leader>sf",
    chat     = "<leader>sc",
    commit   = "<leader>sg",
    run      = "<leader>sx",
    models   = "<leader>sm",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  require("lk.client").setup(M.config)

  -- User commands
  vim.api.nvim_create_user_command("SageExplain",  function() require("lk.actions").explain()        end, { range = true,  desc = "Local Keep AI: explain selection" })
  vim.api.nvim_create_user_command("SageRefactor", function() require("lk.actions").refactor()       end, { range = true,  desc = "Local Keep AI: refactor selection" })
  vim.api.nvim_create_user_command("SageTests",    function() require("lk.actions").generate_tests() end, { desc = "Local Keep AI: generate tests for file" })
  vim.api.nvim_create_user_command("SageFix",      function() require("lk.actions").fix_error()      end, { range = true,  desc = "Local Keep AI: fix errors in selection" })
  vim.api.nvim_create_user_command("SageChat",     function() require("lk.chat").open()              end, { desc = "Local Keep AI: open chat window" })
  vim.api.nvim_create_user_command("SageCommit",   function() require("lk.commit").generate()        end, { desc = "Local Keep AI: generate commit message" })
  vim.api.nvim_create_user_command("SageRun",      function() require("lk.actions").run_prompt()     end, { desc = "Local Keep AI: run agentic task" })
  vim.api.nvim_create_user_command("SageModel",    function() require("lk.actions").switch_model()   end, { desc = "Local Keep AI: switch model" })
  vim.api.nvim_create_user_command("SageModels",   function() require("lk.actions").switch_model()   end, { desc = "Local Keep AI: list/switch models" })

  require("lk.actions").register_keymaps(M.config.keymaps)
end

return M
