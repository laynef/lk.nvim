local M = {}
local client = require("sage.client")
local util   = require("sage.util")

local function run_action(title, prompt, cwd, agent_mode)
  local model = client.read_default_model()
  local _, _, append = util.open_float(title)
  append("⟡ " .. model .. " — " .. title)
  append(string.rep("─", 40))

  local args
  if agent_mode then
    args = { "run", "--model", model, "--quiet", "--prompt", prompt }
  else
    args = { "ask", "--model", model, "--raw", prompt }
  end

  client.run_async(args, cwd, function(line)
    append(line)
  end, function(code)
    if code ~= 0 then append("⚠ exit code " .. code) end
    append("")
    append("── done ──")
  end)
end

function M.explain()
  local sel = util.get_selection()
  if sel == "" then sel = util.get_context_lines(50) end
  local lang = util.get_language()
  local rel = util.get_relative_path()
  local prompt = string.format(
    "Language: %s\nFile: %s\n\n```\n%s\n```\n\nExplain this code clearly and concisely.",
    lang, rel, sel
  )
  run_action("Sage: Explain", prompt, vim.fn.getcwd())
end

function M.refactor()
  local sel = util.get_selection()
  if sel == "" then
    vim.notify("Select code to refactor first", vim.log.levels.WARN)
    return
  end
  local lang = util.get_language()
  local rel  = util.get_relative_path()
  local prompt = string.format(
    "Language: %s\nFile: %s\n\n```\n%s\n```\n\nRefactor for clarity and best practices. Output the improved code.",
    lang, rel, sel
  )
  run_action("Sage: Refactor", prompt, vim.fn.getcwd(), true)
end

function M.generate_tests()
  local file = util.get_file_path()
  local rel  = util.get_relative_path()
  local lang = util.get_language()
  local prompt = string.format(
    "Language: %s\nFile: %s\n\nGenerate comprehensive unit tests for %s covering happy paths, edge cases, and errors.",
    lang, rel, rel
  )
  run_action("Sage: Generate Tests", prompt, vim.fn.getcwd(), true)
end

function M.fix_error()
  local sel = util.get_selection()
  if sel == "" then
    vim.notify("Select the code/error to fix", vim.log.levels.WARN)
    return
  end
  local lang = util.get_language()
  local rel  = util.get_relative_path()
  local prompt = string.format(
    "Language: %s\nFile: %s\n\n```\n%s\n```\n\nFix any errors or issues in this code.",
    lang, rel, sel
  )
  run_action("Sage: Fix", prompt, vim.fn.getcwd(), true)
end

function M.run_prompt()
  vim.ui.input({ prompt = "Sage task: " }, function(task)
    if not task or task == "" then return end
    run_action("Sage: Run", task, vim.fn.getcwd(), true)
  end)
end

function M.switch_model()
  local raw = client.run_sync({ "models", "--all" }, vim.fn.getcwd())
  local models = {}
  for line in raw:gmatch("[^\n]+") do
    local id = line:match("^%s*(cloud:[^%s]+)") or
               line:match("^%s*(openrouter:[^%s]+)") or
               line:match("^%s*(ollama:[^%s]+)") or
               line:match("^%s*(llama_cpp:[^%s]+)")
    if id then table.insert(models, id) end
  end
  if #models == 0 then
    vim.notify("No models found. Is sage installed?", vim.log.levels.ERROR)
    return
  end
  vim.ui.select(models, { prompt = "Select Sage model:" }, function(choice)
    if not choice then return end
    require("sage").config.model = choice
    vim.notify("Sage model: " .. choice, vim.log.levels.INFO)
  end)
end

function M.register_keymaps(maps)
  local function map(key, fn, desc)
    if key and key ~= "" then
      vim.keymap.set({"n","v"}, key, fn, { silent = true, desc = "Sage: " .. desc })
    end
  end
  map(maps.explain,  M.explain,        "Explain")
  map(maps.refactor, M.refactor,       "Refactor")
  map(maps.tests,    M.generate_tests, "Generate Tests")
  map(maps.fix,      M.fix_error,      "Fix Error")
  map(maps.run,      M.run_prompt,     "Run Task")
  map(maps.models,   M.switch_model,   "Switch Model")
end

return M
