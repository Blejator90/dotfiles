-- Neovim Configuration
print("Loading init.lua...")

-- Load core settings first
require('naz.set')
require('naz.remap')
require('naz.diagnostics')

-- Set default colorscheme immediately so you can see something
vim.cmd.colorscheme("default")
print("Default colorscheme set")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  print("Bootstrapping lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

print("Setting up plugins...")

-- Setup plugins with error handling
local ok, err = pcall(function()
  require("lazy").setup("naz.plugins", {
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip", "matchit", "matchparen",
          "tarPlugin", "tohtml", "tutor", "zipPlugin",
        },
      },
    },
    change_detection = { notify = false },
  })
end)

if not ok then
  print("Error loading plugins: " .. tostring(err))
  vim.notify("Plugin loading failed, using minimal config", vim.log.levels.WARN)
else
  print("Plugins loaded successfully")
end


print("Init complete!")

-- Add a simple test command to verify everything works
vim.api.nvim_create_user_command("TestConfig", function()
  vim.notify("Configuration is working!", vim.log.levels.INFO)
end, { desc = "Test if config is working" })

-- Command to open dotfiles
vim.api.nvim_create_user_command("OpenDotfiles", function()
  vim.cmd("tabnew")
  vim.cmd("cd ~/dotfiles/nvim")
  vim.cmd("Telescope find_files")
end, { desc = "Open dotfiles in new tab" })