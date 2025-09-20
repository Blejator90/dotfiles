-- 🔍 Finds the nearest .xcodeproj or .xcworkspace
local function find_xcode_project()
  local result = vim.fs.find(function(name)
    return name:match("%.xcworkspace$") or name:match("%.xcodeproj$")
  end, { upward = true, type = "directory" })
  return result and result[1] or nil
end

-- 📁 Config file for storing preferred schemes per project
local config_file = vim.fn.stdpath("data") .. "/xcode_schemes.json"

-- 💾 Save preferred scheme for current project
local function save_preferred_scheme(project_path, scheme)
  local config = {}
  if vim.fn.filereadable(config_file) == 1 then
    local content = vim.fn.readfile(config_file)
    if #content > 0 then
      local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
      if ok then config = data end
    end
  end

  config[project_path] = scheme
  vim.fn.writefile({vim.json.encode(config)}, config_file)
  vim.notify("💾 Saved scheme '" .. scheme .. "' for this project")
end

-- 📖 Load preferred scheme for current project
local function load_preferred_scheme(project_path)
  if vim.fn.filereadable(config_file) == 0 then return nil end

  local content = vim.fn.readfile(config_file)
  if #content == 0 then return nil end

  local ok, config = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok then return nil end

  local scheme = config[project_path]
  -- Make sure we return nil if scheme is empty string
  if scheme == "" then return nil end
  return scheme
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

  if #schemes > 0 then
    vim.notify("📋 Found " .. #schemes .. " schemes")
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

  local preferred = load_preferred_scheme(project)
  local detected = detect_scheme(project)

  local scheme
  if opts.args and opts.args ~= "" then
    scheme = opts.args
  elseif preferred and preferred ~= "" then
    scheme = preferred
  elseif detected and detected ~= "" then
    scheme = detected
  end

  if not scheme or scheme == "" then
    vim.notify("❌ No scheme provided and none auto-detected", vim.log.levels.ERROR)
    return
  end

  vim.notify("🏗️ Building with scheme: " .. scheme)

  -- Save scheme if manually provided
  if opts.args and opts.args ~= "" then
    save_preferred_scheme(project, opts.args)
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

  local preferred = load_preferred_scheme(project)
  local detected = detect_scheme(project)

  local scheme
  if opts.args and opts.args ~= "" then
    scheme = opts.args
  elseif preferred and preferred ~= "" then
    scheme = preferred
  elseif detected and detected ~= "" then
    scheme = detected
  end

  if not scheme or scheme == "" then
    vim.notify("❌ No scheme provided and none auto-detected", vim.log.levels.ERROR)
    return
  end

  vim.notify("🧪 Testing with scheme: " .. scheme)

  -- Save scheme if manually provided
  if opts.args and opts.args ~= "" then
    save_preferred_scheme(project, opts.args)
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


-- List all available schemes
vim.api.nvim_create_user_command("XcodeListSchemes", function()
  local project = find_xcode_project()
  if not project then
    vim.notify("❌ No .xcodeproj or .xcworkspace found", vim.log.levels.ERROR)
    return
  end

  local cmd
  if project:match("%.xcworkspace$") then
    cmd = string.format("xcodebuild -workspace '%s' -list", project)
  else
    cmd = string.format("xcodebuild -project '%s' -list", project)
  end

  vim.cmd("terminal " .. cmd)
end, {})

-- Set preferred scheme for current project
vim.api.nvim_create_user_command("XcodeSetScheme", function(opts)
  local project = find_xcode_project()
  if not project then
    vim.notify("❌ No .xcodeproj or .xcworkspace found", vim.log.levels.ERROR)
    return
  end

  if not opts.args or opts.args == "" then
    vim.notify("❌ Please provide a scheme name", vim.log.levels.ERROR)
    return
  end

  save_preferred_scheme(project, opts.args)
end, {
  nargs = 1,
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

-- Clear preferred scheme for current project
vim.api.nvim_create_user_command("XcodeClearScheme", function()
  local project = find_xcode_project()
  if not project then
    vim.notify("❌ No .xcodeproj or .xcworkspace found", vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(config_file) == 0 then
    vim.notify("📝 No saved schemes found", vim.log.levels.INFO)
    return
  end

  local content = vim.fn.readfile(config_file)
  if #content == 0 then
    vim.notify("📝 No saved schemes found", vim.log.levels.INFO)
    return
  end

  local ok, config = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok then config = {} end

  config[project] = nil
  vim.fn.writefile({vim.json.encode(config)}, config_file)
  vim.notify("🗑️ Cleared saved scheme for this project")
end, {})
