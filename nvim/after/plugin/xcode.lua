-- 🔍 Finds the nearest .xcodeproj or .xcworkspace
local function find_xcode_project()
  local result = vim.fs.find(function(name)
    return name:match("%.xcworkspace$") or name:match("%.xcodeproj$")
  end, { upward = true, type = "directory" })
  return result and result[1] or nil
end

-- 🔍 Auto-detect scheme from project
local function detect_scheme(project_path)
  local cmd
  if project_path:match("%.xcworkspace$") then
    cmd = string.format("xcodebuild -workspace '%s' -list", project_path)
  else
    cmd = string.format("xcodebuild -project '%s' -list", project_path)
  end

  local output = vim.fn.systemlist(cmd)
  local schemes = {}
  local in_schemes = false
  for _, line in ipairs(output) do
    if in_schemes then
      local name = vim.trim(line)
      if name ~= "" and not name:match("^%s*$") then
        table.insert(schemes, name)
      end
    elseif line:match("^%s*Schemes:") then
      in_schemes = true
    end
  end

  -- Return first scheme or nil
  return schemes[1]
end

-- 🧱 Builds the project
vim.api.nvim_create_user_command("XcodeBuild", function(opts)
  local project = find_xcode_project()
  if not project then
    vim.notify("❌ No .xcodeproj or .xcworkspace found", vim.log.levels.ERROR)
    return
  end

  local scheme = opts.args or detect_scheme(project)
  if not scheme or scheme == "" then
    vim.notify("❌ No scheme provided and none auto-detected", vim.log.levels.ERROR)
    return
  end

  local cmd
  if project:match("%.xcworkspace$") then
    cmd = string.format("xcodebuild -workspace '%s' -scheme '%s' build", project, scheme)
  else
    cmd = string.format("xcodebuild -project '%s' -scheme '%s' build", project, scheme)
  end

  vim.cmd("terminal " .. cmd)
end, {
  nargs = "?",  -- optional single argument
  complete = function()
    -- Optional: use `xcodebuild -list` to return available schemes for autocompletion
    local project = find_xcode_project()
    if not project then return {} end

    local cmd
    if project:match("%.xcworkspace$") then
      cmd = string.format("xcodebuild -workspace '%s' -list", project)
    else
      cmd = string.format("xcodebuild -project '%s' -list", project)
    end

    local output = vim.fn.systemlist(cmd)
    local schemes = {}
    local in_schemes = false
    for _, line in ipairs(output) do
      if in_schemes then
        local name = vim.trim(line)
        if name ~= "" then table.insert(schemes, name) end
      elseif line:match("^Schemes:") then
        in_schemes = true
      end
    end

    return schemes
  end
})

-- Run Xcode Unit Tests
vim.api.nvim_create_user_command("XcodeTest", function(opts)
  local project = find_xcode_project()
  if not project then
    vim.notify("❌ No .xcodeproj or .xcworkspace found", vim.log.levels.ERROR)
    return
  end

  local scheme = opts.args or detect_scheme(project)
  if not scheme or scheme == "" then
    vim.notify("❌ No scheme provided and none auto-detected", vim.log.levels.ERROR)
    return
  end

  -- You can change this destination to a simulator if testing iOS
  local destination = "platform=macOS"

  local cmd
  if project:match("%.xcworkspace$") then
    cmd = string.format("xcodebuild test -workspace '%s' -scheme '%s' -destination '%s'", project, scheme, destination)
  else
    cmd = string.format("xcodebuild test -project '%s' -scheme '%s' -destination '%s'", project, scheme, destination)
  end

  vim.cmd("terminal " .. cmd)
end, {
  nargs = "?",
  complete = function()
    local project = find_xcode_project()
    if not project then return {} end

    local cmd
    if project:match("%.xcworkspace$") then
      cmd = string.format("xcodebuild -workspace '%s' -list", project)
    else
      cmd = string.format("xcodebuild -project '%s' -list", project)
    end

    local output = vim.fn.systemlist(cmd)
    local schemes = {}
    local in_schemes = false
    for _, line in ipairs(output) do
      if in_schemes then
        local name = vim.trim(line)
        if name ~= "" then table.insert(schemes, name) end
      elseif line:match("^Schemes:") then
        in_schemes = true
      end
    end

    return schemes
  end
})
