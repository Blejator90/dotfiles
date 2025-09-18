vim.api.nvim_create_user_command("CRun", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  local compile_cmd = string.format("cc '%s' -o '%s'", file, output)
  local run_cmd = string.format("&& '%s'", output)
  
  -- Open in a horizontal split instead
  vim.cmd("split | terminal " .. compile_cmd .. " " .. run_cmd)
  vim.cmd("resize 15") -- Make it smaller
end, {})
