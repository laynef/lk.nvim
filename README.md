# sage.nvim

Local-first AI coding assistant for Neovim — 200+ free models, no API key needed.

## Install

**lazy.nvim:**
```lua
{
  "sageworksai/sage.nvim",
  config = function()
    require("sage").setup({
      model = "",           -- leave blank to use ~/.sage/config.json default
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
    })
  end
}
```

**vim-plug:**
```viml
Plug 'sageworksai/sage.nvim'
```

## Requires

```bash
pip install sage-ai-cli
sage login
```

## Commands

| Command | Default Key | Description |
|---|---|---|
| `:SageExplain` | `<leader>se` | Explain selection |
| `:SageRefactor` | `<leader>sr` | Refactor selection (writes file) |
| `:SageTests` | `<leader>st` | Generate tests for current file |
| `:SageFix` | `<leader>sf` | Fix errors in selection |
| `:SageChat` | `<leader>sc` | Open floating chat panel |
| `:SageCommit` | `<leader>sg` | Generate commit message |
| `:SageRun` | `<leader>sx` | Run agentic task (prompt) |
| `:SageModels` | `<leader>sm` | List and switch models |

All commands work on visual selections where applicable.
