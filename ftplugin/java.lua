--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- `java.lua`: sets up JDTLS

local root_files = {
    ".classpath", -- Is this only ever in the project root?
    ".git",
    ".gitignore",
    "LICENSE",
    "LICENSE.txt",
    "README.md",
    "README.txt",
    "build.gradle",
    "gradlew",
    "mvnw",
    "pom.xml"
}

local features = {
    codelens = true, -- Finds references to symbols throughout a project
    debug = false    -- Relies on nvim-dap, java-test, and java-debug-adapter
}

local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })

--- Enable codelens to search throughout the project for references to symbols.
---
--- Manually triggers a refresh once, then sets up a refresh after every write.
---
--- @param buffnr integer The buffer ID to register the autocmd in
local function enable_codelens(buffnr)
    pcall(vim.lsp.codelens.refresh)

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = buffnr,
        group = java_cmds,
        desc = "Refresh codelens",
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end
    })
end

--- Registers an autocmd to format before writing to file.
---
--- @param buffnr integer The buffer ID to register the autocmd in
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

--- Setup the given buffer for Java.
---
--- - Enables codelens (if `features.codelens` is true)
--- - Registers keymaps
--- - Enables autoformatting
---
--- @param client vim.lsp.Client The LSP client being attached
--- @param buffnr integer The buffer ID to setup
local function jdtls_on_attach(client, buffnr)
    if features.codelens then
        enable_codelens(buffnr)
    end

    require("config.keymap").java(root_files).setup(buffnr)

    enable_format_on_write(buffnr)
end

local cache_vars = {}

--- Attempt to find a codestyle associated with the current project or fallback to a default style.
---
--- For example, if given `"path/to/Astral"`, it will search for
--- `"CONFIG/codestyle/java/Astral.xml"`.
---
--- Defaults to `"CONFIG/codestyle/java/eclipse-java-google-style.xml"`.
---
--- @param project_root path? A path to the root directory of the current project
--- @return path
local function get_codestyle_path(project_root)
    --- Search for a codestyle in `"CONFIG/codestyles/java/CODESTYLE.xml"`.
    ---
    --- @param codestyle string The file name (without `".xml"`) of the codestyle to search for
    --- @return path codestyle_path A possible path to a codestyle definition
    local function generate_codestyle_path(codestyle)
        return vim.fs.joinpath(vim.fn.stdpath("config"), "codestyles", "java", codestyle .. ".xml")
    end

    project_root = vim.fs.basename(project_root)

    local codestyle_path = generate_codestyle_path(project_root or "")

    if vim.fn.filereadable(codestyle_path) == 1 then
        -- Project-specific Neovim settings, located in
        -- `"CONFIG/lua/codestyles/java/PROJECT_ROOT.lua"`.
        if pcall(require, "codestyles.java." .. project_root) then
            vim.notify("Using codestyle '" .. project_root .. "' and settings from project.")
        else
            vim.notify("Using codestyle '" .. project_root .. "'.")
        end
    else -- Revert to default codestyle
        local default_codestyle = "eclipse-java-google-style"
        codestyle_path = generate_codestyle_path(default_codestyle)

        if vim.fn.filereadable(codestyle_path) == 1 then
            vim.notify("Using codestyle '" .. default_codestyle .. "'.")
        else
            error(
                string.format(
                    "Could not find codestyle '%s' or '%s'!", default_codestyle, project_root
                ),
                1
            )
        end
    end

    return codestyle_path
end


--- Get various paths related to JDTLS.
---
--- @return { base_data_dir: path, java_agent: path, launcher_jar: path, platform_config: path, runtimes: path?, bundles: path? }
local function get_paths()
    if cache_vars.paths then
        vim.notify("`cache_vars` existed")
        return cache_vars.paths
    end

    local paths = {}
    paths.base_data_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "nvim-jdtls")

    -- E.g., `"/home/USER/.local/share/nvim/mason/share/jdtls"`.
    local jdtls_share = vim.fs.joinpath(vim.fn.expand("$MASON"), "share", "jdtls")
    paths.java_agent = vim.fs.joinpath(jdtls_share, "lombok.jar")
    paths.launcher_jar = vim.fs.joinpath(jdtls_share, "plugins", "org.eclipse.equinox.launcher.jar")

    -- Previously, platform selection was handled in Lua, but mason.nvim's package for JDTLS
    -- handles it:
    --
    -- <https://github.com/mason-org/mason-registry/blob/bc456ee/packages/jdtls/package.yaml#L42>
    paths.platform_config = vim.fs.joinpath(jdtls_share, "config")

    -- paths.runtimes = ... -- If you're using multiple java runtimes
    -- paths.bundles = ... -- DAP and other JDTLS plugins
    cache_vars.paths = paths

    return paths
end

--- The main JDTLS setup.
local function jdtls_setup()
    local jdtls = require("jdtls")

    local paths = get_paths()

    local current_data_dir = vim.fs.joinpath(
        paths.base_data_dir,
        -- Gets parent directory (e.g., `"path/to/file.extension"` returns `"to"`).
        vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    )

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

    --- The command to start the language server.
    local cmd = {
        "java", -- Execution path for the JRE

        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",

        "-Xmx1g",

        "--add-modules=ALL-SYSTEM",

        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",

        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",

        "-jar",
        paths.launcher_jar,

        "-configuration",
        paths.platform_config,

        "-data",
        current_data_dir
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
        --- Adds hints into code, e.g. names for method inputs
        inlayHints = {
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
        signatureHelp = { -- Seems to provide the info for popups with method info when using it
            enabled = true
        },
        -- -- Always provide autocomplete with methods, etc. from specified packages, even if not imported
        -- completion = { favoriteStaticMembers = {} }
        contentProvider = {
            preferred = "fernflower" -- Usually a third party decompiler ID
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
        sources = { -- What does this mean/do?
            starThreshold = 9999,
            staticStarThreshold = 9999
        }
    }

    --- @type vim.lsp.ClientConfig
    local config = {
        cmd = cmd,
        settings = lsp_settings,
        on_attach = jdtls_on_attach,
        capabilities = cache_vars.capabilities,
        root_dir = root_path,
        flags = {
            exit_timeout = false, -- Default
            debounce_text_changes = 150, -- Default
            allow_incremental_sync = true
        },
        init_options = {
            bundles = paths.bundles
        }
    }

    jdtls.start_or_attach(config)
end

jdtls_setup()
