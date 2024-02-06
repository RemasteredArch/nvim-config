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

end

local function jdtls_setup(event)
	local jdtls = require("jdtls")

	local config = {
		cmd = {"<imagine-this-is-the-command-that-starts-jdtls>"},
		root_dir = jdtls.setup.find_root(root_files),
		on_attach = jdtls_on_attach
	}

	jdtls.start_or_attach(config)
end

vim.api.nvim_create_autocmd("FileType", {
	group = java_cmds,
	pattern = {"java"},
	desc = "Setup jdtls",
	callback = jdtls_setup
})
