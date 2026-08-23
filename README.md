<p align="center">
  <img src="https://raw.githubusercontent.com/laynef/lk.nvim/main/lk-icon.png" width="96" alt="Local Keep AI" />
</p>

# lk.nvim — Local Keep AI for Neovim

Local-first AI coding assistant for Neovim — 1,000+ free models, no API key needed.

## Install

**lazy.nvim:**
```lua
{
  "laynef/lk.nvim",
  config = function()
    require("lk").setup({
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
Plug 'laynef/lk.nvim'
```

## Requires

```bash
pip install local-keep-ai-cli
lk login
```

## Commands

| Command | Default Key | Description |
|---|---|---|
| `:LKExplain` | `<leader>se` | Explain selection |
| `:LKRefactor` | `<leader>sr` | Refactor selection (writes file) |
| `:LKTests` | `<leader>st` | Generate tests for current file |
| `:LKFix` | `<leader>sf` | Fix errors in selection |
| `:LKChat` | `<leader>sc` | Open floating chat panel |
| `:LKCommit` | `<leader>sg` | Generate commit message |
| `:LKRun` | `<leader>sx` | Run agentic task (prompt) |
| `:LKModels` | `<leader>sm` | List and switch models |

All commands work on visual selections where applicable.
