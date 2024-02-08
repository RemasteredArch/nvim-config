-- almost directly copied from https://lsp-zero.netlify.app/v3.x/guide/setup-with-nvim-jdtls.html

local java_cmds = vim.api.nvim_create_augroup("java_cmds", {clear = true})

local cache_vars = {}

local features = {
	codelens = true, -- finds refrences to methods throughout a project
	debugger = false -- relies on nvim-dap, java-test and java-debug-adapter
}

local root_files = {
	".git",
	"mvnw",
	"gradlew",
	"pom.xml",
	"build.gradle"
}

local function get_codestyle_path()
	local codestyle = vim.fn.stdpath("data") .. "/codestyles/eclipse-java-google-style.xml"

	if vim.fn.filereadable(codestyle) == 0 then
		vim.notify("Codestyle '" .. codestyle .. "' not found!")
	end

	return codestyle

	-- maybe add some checking for project-specific codestyles?
end

local function get_jdtls_paths()
	if cache_vars.paths then
		return cache_vars.paths
	end

	local path = {}

	path.data_dir = vim.fn.stdpath("cache") .. "/nvim-jdtls"

	local jdtls_install = require("mason-registry").get_package("jdtls"):get_install_path()

	path.java_agent = jdtls_install .. "/lombok.jar"
	path.launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")

	if vim.fn.has("mac") == 1 then
		path.platform_config = jdtls_install .. "/config_mac"
	elseif vim.fn.has("unix") == 1 then
		path.platform_config = jdtls_install .. "/config_linux"
	elseif vim.fn.has("win32") == 1 then
		path.platform_config = jdtls_install .. "/config_win"
	end

	-- <insert test and debug setup here>

	-- path.runtimes = {} -- if you're using multiple java runtimes

	cache_vars = path

	return path
end

local function enable_codelens(buffnr)
	pcall(vim.lsp.codelens.refresh)

	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buffnr,
		group = java_cmds,
		desc = "Refresh codelens",
		callback = function ()
			pcall(vim.lsp.codelens.refresh)
		end
	})
end

-- <enable_debugger(bufnr)> here

local function jdtls_on_attach(client, buffnr)
	--[[if features.debugger then
		enable_debugger(bufnr)
	end]]--

	if features.codelens then
		enable_codelens(buffnr)
	end

	-- https://github.com/mfussenegger/nvim-jdtls#usage

	-- in normal mode, press alt+o[rganize] to organize imports
	vim.keymap.set("n", "<A-o>", "<cmd>lua require('jdtls').organize_imports()<cr>", opts)

	-- in normal and visual mode mode, press c,r[efactor],v[ariable] to extract a variable
	vim.keymap.set("n", "crv", "<cmd>lua require('jdtls').extract_variable()<cr>", opts) 
	vim.keymap.set("x", "crv", "<ec><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)

	-- in normal and visual mode, press c,r[efactor],c[onstant] to extract a constant
	vim.keymap.set("n", "crc", "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
	vim.keymap.set("x", "crc", "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)

	-- in visual mode, press c,r[efactor],m[ethod] to extract a method
	vim.keymap.set("x", "crm", "<cmd>lua require('jdtls').extract_method(true)<cr>", opts)
end

local function jdtls_setup(event)
	vim.notify("setting up jtdls...")
	local pkg_status, jdtls = pcall(require, "jdtls")
	if not pkg_status then
		vim.notify("Unable to load nvim-jdtls, further, the JVM may be nonfunctional, try java -version", "error")
		return
	end
	--local jdtls = require("jdtls")

	local path = get_jdtls_paths()
	local data_dir = path.data_dir .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

	if cache_vars.capabilities == nil then
		jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

		local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
		cache_vars.capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities() or {}
		)
	end

	local cmd = { -- command to start the language server
		"java", -- execution path for the JRE

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens", "java.base/java.util=ALL-UNNAMED",
		"--add-opens", "java.base/java.lang=ALL-UNNAMED",

		"-jar", path.launcher_jar,
		"-configuration", path.platform_config,

		"-data", data_dir
	}

	local lsp_settings = {
		eclipse = {
			downloadSources = true
		},
		configuration = {
			updateBuildConfiguration = "interactive",
			runtimes = path.runtimes
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
				profile = get_codestyle_path()
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
		--[[codeGeneration = {
			toString = {
				template = "${object.className}{${member.name()}=${$member.value}, ${otherMembers}}"
			},
			useBlocks = true
		}]]--
	}

	jdtls.start_or_attach({
		cmd = cmd,
		settings = lsp_settings,
		on_attach = jdtls_on_attach,
		capabilities = cache_vars.capabilities,
		root_dir = jdtls.setup.find_root(root_files),
		flags = {
			allow_incremental_sync = true
		},
		init_options = {
			bundles = path.bundles
		}
	})
end

vim.api.nvim_create_autocmd("FileType", {
	group = java_cmds,
	pattern = "*.java",
	desc = "Setup jdtls",
	callback = jdtls_setup
})
