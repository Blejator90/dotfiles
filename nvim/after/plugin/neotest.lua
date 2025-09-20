-- neotest.lua: Modern test runner configuration

-- Only load Swift adapter if available
local adapters = {
  require("neotest-jest")({
    jestCommand = "npm test --",
    jestConfigFile = "package.json",
    env = { CI = true },
    cwd = function(path)
      return vim.fn.getcwd()
    end,
  }),
}

-- Try to load Swift testing adapter
local ok, swift_adapter = pcall(require, "neotest-swift-testing")
if ok then
  table.insert(adapters, swift_adapter)
end

require("neotest").setup({
  adapters = adapters,

  -- Show test output in floating window
  output = {
    enabled = true,
    open_on_run = "short",
  },

  -- Show test status in sign column
  status = {
    enabled = true,
    signs = true,
    virtual_text = true,
  },

  -- Quickfix integration
  quickfix = {
    enabled = true,
    open = false,
  },
})

-- Enhanced neotest keybindings for all languages
vim.keymap.set("n", "<leader>tn", function() require("neotest").run.run() end, { desc = "Run test at cursor" })
vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run all tests in file" })
vim.keymap.set("n", "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, { desc = "Run all tests" })
vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Open test output" })
vim.keymap.set("n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
vim.keymap.set("n", "<leader>tp", function() require("neotest").run.stop() end, { desc = "Stop running tests" })