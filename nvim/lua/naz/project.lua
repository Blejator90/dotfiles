-- Project detection and management system
local M = {}

-- Cache for project detection results
local cache = {}

-- Detect JavaScript/TypeScript project type and tools
function M.detect_js_project()
  local cwd = vim.fn.getcwd()

  -- Check cache first
  if cache[cwd] and cache[cwd].js then
    return cache[cwd].js
  end

  local result = {
    has_package_json = vim.fn.filereadable("package.json") == 1,
    has_tsconfig = vim.fn.filereadable("tsconfig.json") == 1,
    has_yarn = vim.fn.filereadable("yarn.lock") == 1,
    has_pnpm = vim.fn.filereadable("pnpm-lock.yaml") == 1,
    has_bun = vim.fn.filereadable("bun.lockb") == 1,
    package_manager = "npm", -- default
    is_nestjs = false,
    test_runner = nil,
  }

  -- Determine package manager
  if result.has_bun then
    result.package_manager = "bun"
  elseif result.has_pnpm then
    result.package_manager = "pnpm"
  elseif result.has_yarn then
    result.package_manager = "yarn"
  end

  -- Check for NestJS
  if result.has_package_json then
    local package = vim.fn.json_decode(vim.fn.readfile("package.json"))
    if package and package.dependencies then
      result.is_nestjs = package.dependencies["@nestjs/core"] ~= nil

      -- Detect test runner
      if package.devDependencies then
        if package.devDependencies["jest"] then
          result.test_runner = "jest"
        elseif package.devDependencies["vitest"] then
          result.test_runner = "vitest"
        elseif package.devDependencies["mocha"] then
          result.test_runner = "mocha"
        end
      end

      -- Store available scripts
      result.scripts = package.scripts or {}
    end
  end

  -- Cache the result
  cache[cwd] = cache[cwd] or {}
  cache[cwd].js = result

  return result
end

-- Detect C/C++ project type
function M.detect_c_project()
  local cwd = vim.fn.getcwd()

  if cache[cwd] and cache[cwd].c then
    return cache[cwd].c
  end

  local result = {
    has_makefile = vim.fn.filereadable("Makefile") == 1 or vim.fn.filereadable("makefile") == 1,
    has_cmake = vim.fn.filereadable("CMakeLists.txt") == 1,
    has_meson = vim.fn.filereadable("meson.build") == 1,
    has_configure = vim.fn.filereadable("configure") == 1,
    compiler = "cc", -- default
    build_system = nil,
  }

  -- Determine build system priority
  if result.has_cmake then
    result.build_system = "cmake"
  elseif result.has_makefile then
    result.build_system = "make"
  elseif result.has_meson then
    result.build_system = "meson"
  elseif result.has_configure then
    result.build_system = "autotools"
  end

  -- Check for compiler preference
  if vim.fn.executable("clang") == 1 then
    result.compiler = "clang"
  elseif vim.fn.executable("gcc") == 1 then
    result.compiler = "gcc"
  end

  cache[cwd] = cache[cwd] or {}
  cache[cwd].c = result

  return result
end


-- Clear cache when changing directories
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    cache = {}
  end,
})

return M