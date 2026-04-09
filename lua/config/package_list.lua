--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024-2026 RemasteredArch

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

-- `package_list.lua`: lists of all Tree-sitter, Mason, and Lazy packages, intended only for use in
-- `packages.lua`.

--- @class (exact) PackageListMason
--- @field linter table<string, string[]>
--- @field formatter table<string, string[]>
--- @field lsp string[]
--- @field dap string[]
--- @field other string[]
---
--- @class (exact) PackageList
--- @field treesitter string[]
--- @field lazy LazySpec
--- @field mason PackageListMason

local nix = require("util.nix")

--- @type PackageList
local list = {
    treesitter = {
        "astro",
        "bash",
        "c",
        "c_sharp",
        "caddy",
        "cmake",
        "cpp",
        "css",
        "dart",
        "diff",
        "dockerfile",
        "editorconfig",
        "git_config",
        "git_rebase",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "html",
        "ini",
        "java",
        "javadoc",
        "javascript",
        "json",
        "just",
        "kotlin",
        "linkerscript",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "query",
        "regex",
        "rust",
        "sql",
        "ssh_config",
        "tmux",
        "toml",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "xml",
        "yaml"
    },
    lazy = {}, -- Defined below
    mason = {
        linter = {
            yaml = {
                "actionlint" -- GitHub Actions workflow files
            },
            sql = {
                "sqruff"
            },
            dockerfile = {
                "hadolint"
            }
        },
        formatter = {
            markdown = { "mdformat" },
            yaml = { "yamlfmt" },
            sql = { "sqruff" },
            bash = { "shfmt" },
            sh = { "shfmt" }
        },
        lsp = {
            "astro",                                -- Astro web framework.
            "bashls",                               -- Integrates with ShellCheck.
            "biome",                                -- JS, TS, JSX, TSX, JSON, and JSONC.
            not nix.is_nixos() and "clangd" or nil, -- C and C++ (needs NixOS-specific package).
            "cssls",                                -- CSS.
            "gradle_ls",                            -- Gradle build scripts.
            "harper_ls",                            -- Spelling and grammar checking.
            "html",                                 -- HTML.
            "jdtls",                                -- Java, see also `ftplugin/java.lua`.
            "jsonls",                               -- JSON.
            "lemminx",                              -- XML.
            "lua_ls",                               -- Lua, also configured by lazydev.nvim.
            "markdown_oxide",                       -- Markdown.
            "marksman",                             -- Markdown.
            "neocmake",                             -- CMake build scripts.
            nix.has_nix() and "nil_ls" or nil,      -- Nix.
            -- "rust_analyzer", -- Install with `rustup compent add rust-analyzer` instead.
            "sqls",                                 -- SQL.
            "taplo",                                -- TOML.
            "tinymist",                             -- Typst.
            "vtsls",                                -- JavaScript and TypeScript.
            "yamlls"                                -- YAML.
        },
        dap = {
            "codelldb" -- C++ and Rust are first-class, but also supports C, Swift, Zig, Ada, etc.
        },
        other = {
            "shellcheck", -- Shell script (Bash, POSIX, etc.) linter.
            "mdformat"    -- Markdown formatter.
        }
    }
}

list.lazy = {
    require("plugins.nvim-treesitter").with_ensure_installed(list.treesitter),

    -- Color scheme.
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            integrations = {
                mason = true
            },
            custom_highlights = function(colors)
                return {
                    FloatTitle = {
                        link = "FloatBorder"
                    }
                }
            end

        },
        priority = 1000
    },

    -- Code screenshots
    require("plugins.silicon"),

    {
        "ziontee113/icon-picker.nvim",
        lazy = true,
        config = function()
            require("icon-picker").setup({ disable_legacy_commands = true })
        end
    },

    -- Searching.
    require("plugins.nvim-rip-substitute"),

    -- UI.
    { "stevearc/dressing.nvim" },
    require("plugins.telescope"),

    -- Startup.
    require("plugins.alpha"),

    -- Package management.
    { "mason-org/mason.nvim" },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = true
    },
    -- Lockfile for Mason.
    --
    -- Creates `:MasonLock` and `:MasonLockRestore`, autoupdates on updates/installs with `:Mason`.
    {
        "zapling/mason-lock.nvim",
        init = function()
            require("mason-lock").setup()
        end
    },

    -- Linters.
    { "mfussenegger/nvim-lint" },

    -- Formatters.
    {
        "stevearc/conform.nvim"
        -- maybe call config.format here instead of config.packages for lazy loading?
    },

    -- LSP/DAP.
    { "mason-org/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/nvim-cmp" },
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp"
    },

    { -- not sure if this works lazy loaded
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        }
    },

    -- Language-specific.
    { "mrcjkb/rustaceanvim",     lazy = false },
    { "mfussenegger/nvim-jdtls", lazy = true },
    require("plugins.lazydev"),
    require("plugins.markdown_preview"),
    require("plugins.typst_preview"),
    {
        "nanotee/sqls.nvim",
        ft = { "sql" }
    },

    -- Write files with superuser permissions.
    { "lambdalisue/vim-suda" }
}

return list
