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
  require("sage.client").setup(M.config)

  -- User commands
  vim.api.nvim_create_user_command("SageExplain",  function() require("sage.actions").explain()        end, { range = true,  desc = "Sage: explain selection" })
  vim.api.nvim_create_user_command("SageRefactor", function() require("sage.actions").refactor()       end, { range = true,  desc = "Sage: refactor selection" })
  vim.api.nvim_create_user_command("SageTests",    function() require("sage.actions").generate_tests() end, { desc = "Sage: generate tests for file" })
  vim.api.nvim_create_user_command("SageFix",      function() require("sage.actions").fix_error()      end, { range = true,  desc = "Sage: fix errors in selection" })
  vim.api.nvim_create_user_command("SageChat",     function() require("sage.chat").open()              end, { desc = "Sage: open chat window" })
  vim.api.nvim_create_user_command("SageCommit",   function() require("sage.commit").generate()        end, { desc = "Sage: generate commit message" })
  vim.api.nvim_create_user_command("SageRun",      function() require("sage.actions").run_prompt()     end, { desc = "Sage: run agentic task" })
  vim.api.nvim_create_user_command("SageModel",    function() require("sage.actions").switch_model()   end, { desc = "Sage: switch model" })
  vim.api.nvim_create_user_command("SageModels",   function() require("sage.actions").switch_model()   end, { desc = "Sage: list/switch models" })

  require("sage.actions").register_keymaps(M.config.keymaps)
end

return M
