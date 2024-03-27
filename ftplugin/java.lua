local root_files = {
  "README.md",
  ".git",
  ".gitignore",
  "mvnw",
  "gradlew",
  "pom.xml",
  "build.gradle",
  "LICENSE",
  ".classpath" -- is this only ever in the project root?
}

local features = {
  codelens = true, -- finds references to methods throughout a project
  debug = false    -- relies on nvim-dap, java-test, and java-debug-adapter
}

local function enable_codelens(buffnr)
  pcall(vim.lsp.codelens.refresh)

  local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buffnr,
    group = java_cmds,
    desc = "Refresh codelens",
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end
  })
end

local function enable_format_on_write(buffnr)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buffnr,
    group = java_cmds,
    desc = "Format on write",
    callback = function()
      vim.lsp.buf.format()
    end
  })
end

local function set_keymap(buffnr)
  local opts = {}

  local function set_bind(mode, lhs, rhs)
    vim.api.nvim_buf_set_keymap(buffnr, mode, lhs, rhs, opts)
  end

  -- look into binding JdtCompile, JdtJshell, and maybe JdtJol
  -- https://github.com/mfussenegger/nvim-jdtls#usage

  -- in normal mode, press alt+o[rganize] to organize imports
  set_bind("n", "<A-o>", "<cmd>lua require('jdtls').organize_imports()<cr>")

  -- in normal and visual mode mode, press c,r[efactor],v[ariable] to extract a variable
  set_bind("n", "crv", "<cmd>lua require('jdtls').extract_variable()<cr>")
  set_bind("x", "crv", "<ec><cmd>lua require('jdtls').extract_variable(true)<cr>")

  -- in normal and visual mode, press c,r[efactor],c[onstant] to extract a constant
  set_bind("n", "crc", "<cmd>lua require('jdtls').extract_constant()<cr>")
  set_bind("x", "crc", "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>")

  -- in visual mode, press c,r[efactor],m[ethod] to extract a method
  set_bind("x", "crm", "<cmd>lua require('jdtls').extract_method(true)<cr>")

  -- in normal mode, press space,r[un] to run the single-file code in the current buffer (or c[onfig]r[un] to run with input)
  set_bind("n", "<leader>r", "<cmd>split | term java %<cr>")
  set_bind("n", "<leader>cr", [[<cmd>lua function()
    local user_input = vim.fn.input('Args: ')
    vim.api.nvim_command('split | term java % ' .. user_input)
  end<cr>]])
  -- same but space,f[ull],r[un] (or space,f[ull],c[onfig],r[un]) for multiple files
  -- see: https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fcore%2Fresources%2Fpackage-summary.html
  -- see: https://github.com/eclipse-jdtls/eclipse.jdt.ls/blob/27a1a1e1f6e1b598b5d9cb5ef00b3783b7ee458a/org.eclipse.jdt.ls.core/src/org/eclipse/jdt/ls/core/internal/handlers/BuildWorkspaceHandler.java#L47
  -- see: incremental builds https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fcore%2Fresources%2FIncrementalProjectBuilder.html&anchor=FULL_BUILD
  --[[set_bind("n", "<leader>fr", function()
		vim.api.nvim_command("JdtCompile")
		local bin_dir = require("jdtls").setup.find_root(root_files) .. "/bin"
		print(bin_dir)
		--vim.api.nvim_command("split | term java % <cr>")
	end)]]
end

local function jdtls_on_attach(client, buffnr)
  if features.codelens then
    enable_codelens(buffnr)
  end

  set_keymap(buffnr)

  enable_format_on_write(buffnr)
end

local cache_vars = {}

local function generate_codestyle_path(codestyle)
  return vim.fn.stdpath("config") .. "/codestyles/java/" .. codestyle .. ".xml"
end

local function get_codestyle_path(project_root)
  project_root = vim.fs.basename(project_root)
  local codestyle_path
  if not project_root == nil then -- in case jdtls can't detect a root folder
    codestyle_path = generate_codestyle_path(project_root)
  end

  if vim.fn.filereadable(codestyle_path) == 1 then
    local ok_project_settings = pcall(require, "codestyles/java/" .. project_root) -- project specific nvim settings, located in <config>/lua/codestyles/java/
    if ok_project_settings then
      vim.notify("Using codestyle '" .. project_root .. "' and settings from project.")
    else
      vim.notify("Using codestyle '" .. project_root .. "'.")
    end
  else -- revert to default codestyle
    local codestyle = "eclipse-java-google-style"
    codestyle_path = generate_codestyle_path(codestyle)
    if vim.fn.filereadable(codestyle_path) == 1 then
      vim.notify("Using codestyle '" .. codestyle .. "'.")
    else
      vim.notify("Could not find codestyle '" .. codestyle .. "' or '" .. project_root .. "'!")
      -- maybe automatically download from https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml
    end
  end

  return codestyle_path
end

local function get_paths()
  if cache_vars.paths then
    vim.notify("cache_vars existed")
    return cache_vars.paths
  end

  local paths = {}
  paths.base_data_dir = vim.fn.stdpath("cache") .. "/nvim-jdtls/"

  local jdtls_install = require("mason-registry").get_package("jdtls"):get_install_path()

  paths.java_agent = jdtls_install .. "/lombok.jar"

  paths.launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")


  if vim.fn.has("unix") == 1 then
    paths.platform_config = jdtls_install .. "/config_linux"
  elseif vim.fn.has("win32") == 1 then
    paths.platform_config = jdtls_install .. "/config_win"
  elseif vim.fn.has("mac") == 1 then
    paths.platform_config = jdtls_install .. "/config_mac"
  end

  -- paths.runtiles = ... -- if you're using multiple java runtimes
  -- paths.bundles = ... -- DAP and other JDTLS plugins

  cache_vars.paths = paths

  return paths
end

local function jdtls_setup(event)
  local jdtls = require("jdtls")

  local paths = get_paths()
  local current_data_dir = paths.base_data_dir ..
      vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") -- gets parent directory (e.g. path/to/file.extension returns "to")
  local root_path = jdtls.setup.find_root(root_files)

  if cache_vars.capabilities == nil then
    jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    cache_vars.capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities() or {},
      ok_cmp and cmp_lsp.default_capabilities() or {}
    )
  end

  local cmd = { -- command to start the language server
    "java",     -- execution path for the JRE

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",

    "-jar", paths.launcher_jar,
    "-configuration", paths.platform_config,

    "-data", current_data_dir
  }

  local lsp_settings = {
    eclipse = {
      downloadSources = true
    },
    configuration = {
      updateBuildConfiguration = "interactive",
      runtimes = paths.runtimes
    },
    maven = {
      downloadSources = true
    },
    implementationsCodeLens = {
      enabled = true
    },
    referencesCodeLens = {
      enabled = true
    },
    inlayHints = { -- adds hints into code, e.g. names for method inputs
      parameterNames = {
        enabled = "all"
      }
    },
    format = {
      enabled = true,
      settings = {
        profile = get_codestyle_path(root_path)
      }
    },
    signatureHelp = { -- seems to provide the info for popups with method info when using it
      enabled = true
    },
    -- completion = { favoriteStaticMembers = {} } -- always provide autocomplete with methods, etc. from specified packages, even if not imported
    contentProvider = {
      preferred = "fernflower" -- usually a third party decomplier ID
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = { -- what does this mean/do?
      starThreshold = 9999,
      staticStarThreshold = 9999
    },
  }

  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = cache_vars.capabilities,
    root_dir = root_path,
    flags = {
      allow_incremental_sync = true
    },
    init_options = {
      bundles = paths.bundles
    }
  })
end

jdtls_setup()
