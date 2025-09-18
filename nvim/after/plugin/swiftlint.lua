-- SwiftLint integration for Swift files
local swiftlint_group = vim.api.nvim_create_augroup("SwiftLint", { clear = true })

-- Function to parse SwiftLint output and set diagnostics
local function run_swiftlint_diagnostics()
  local file = vim.fn.expand("%:p")
  local cmd = string.format("/opt/homebrew/bin/swiftlint lint --reporter json '%s'", file)
  local output = vim.fn.system(cmd)
  
  if vim.v.shell_error == 0 then
    -- Parse JSON output and create diagnostics
    local ok, result = pcall(vim.json.decode, output)
    if ok and result then
      local diagnostics = {}
      for _, issue in ipairs(result) do
        if issue.file == file then
          table.insert(diagnostics, {
            lnum = (issue.line or 1) - 1,  -- 0-indexed
            col = (issue.character or 1) - 1,
            message = issue.reason,
            severity = issue.severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            source = "swiftlint"
          })
        end
      end
      
      -- Set diagnostics for current buffer
      vim.diagnostic.set(vim.api.nvim_create_namespace("swiftlint"), 0, diagnostics)
    end
  end
end

-- Run diagnostics on save and text change
vim.api.nvim_create_autocmd({"BufWritePost", "TextChanged", "InsertLeave"}, {
  group = swiftlint_group,
  pattern = "*.swift",
  callback = run_swiftlint_diagnostics
})

-- Manual lint command
vim.api.nvim_create_user_command("SwiftLint", function()
  vim.cmd("!swiftlint lint %")
end, {})

-- Auto-fix command
vim.api.nvim_create_user_command("SwiftLintFix", function()
  vim.cmd("!swiftlint autocorrect %")
  vim.cmd("edit!")
end, {})