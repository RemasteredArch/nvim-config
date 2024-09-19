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

-- package_list.lua: lists of all Treesitter, Mason, and Lazy packages, intended only for use in packages.lua

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

--- @type PackageList
local list = {
    treesitter = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "html",
        "java",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
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
            }
        },
        formatter = {
            markdown = { "mdformat" },
            yaml = { "yamlfmt" }
        },
        lsp = {
            "bashls",         -- Integrates with shellcheck
            "biome",          -- JS, TS, JSX, TSX, JSON, and JSONC
            "clangd",         -- C and C++
            "gradle_ls",      -- Gradle build scripts
            "html",           -- HTML
            "harper_ls",      -- Spelling and grammar checking
            "jdtls",          -- Java, see also see ftplugin/java.lua
            "lemminx",        -- XML
            "lua_ls",         -- Lua, also configured by Neodev for Neovim configuration files
            "markdown_oxide", -- Markdown
            "marksman",       -- Markdown
            "neocmake",       -- CMake build scripts
            -- "rust_analyzer", -- Install with `rustup compent add rust-analyzer` instead where possible
            "taplo",          -- TOML
            "vtsls",          -- JS and TS
            "yamlls"
        },
        dap = {
            "codelldb" -- C++ and Rust are first-class, but also supports C, Swift, Zig, Ada, etc.
        },
        other = {
            "shellcheck", -- Bash and SH linter
            "mdformat"    -- Markdown formatter
        }
    }
}

list.lazy = {
    -- Tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")

            --- @diagnostic disable-next-line:missing-fields
            configs.setup({
                -- List of parsers to always have installed, the first 5 are required
                -- List with :TSInstallInfo
                ensure_installed = list.treesitter,
                -- Install the above ensured parsers synchronously
                sync_install = false,

                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                }
            })
        end
    },

    -- Color scheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000
    },

    -- Code screenshots
    require("config.silicon"),

    {
        "ziontee113/icon-picker.nvim",
        lazy = true,
        config = function()
            require("icon-picker").setup({ disable_legacy_commands = true })
        end
    },

    -- Searching
    {
        "chrisgrieser/nvim-rip-substitute",
        cmd = "RipSubstitute",
        keys = {
            {
                "<leader>rs",
                function()
                    require("rip-substitute").sub()
                end,
                mode = { "n", "x" },
                desc = " substitute with ripgrep"
            }
        },
        config = function()
            require("rip-substitute").setup({
                popupWin = {
                    title = " substitute with ripgrep"
                },
                prefill = {
                    normal = false,
                    visual = false
                },
                regexOptions = {
                    autoBraceSimpleCaptureGroups = true -- $1 -> ${1} because $1a != ${1}a (breaks named capture groups)
                }
            })
        end
        -- Regex reference: https://docs.rs/regex/1.10.5/regex/#syntax
    },

    -- UI
    {
        "stevearc/dressing.nvim"
        -- opts = {} -- e.g. insert_only = true by default
    },
    { -- startup
        "goolord/alpha-nvim",
        dependencies = {
            {
                "nvim-tree/nvim-web-devicons",
                config = function()
                    require("nvim-web-devicons").setup()
                end
            }
        },
        config = function()
            require("config.alpha")
        end
    },

    -- Package management
    { "williamboman/mason.nvim" },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = true
    },
    -- Lockfile for Mason
    -- Creates `:MasonLock` and `:MasonLockRestore`, autoupdates on updates/installs with `:Mason`
    {
        "zapling/mason-lock.nvim",
        init = function()
            require("mason-lock").setup()
        end
    },

    -- Linters
    { "mfussenegger/nvim-lint" },

    -- Formatters
    {
        "stevearc/conform.nvim"
        -- maybe call config.format here instead of config.packages for lazy loading?
    },

    -- LSP/DAP
    { "williamboman/mason-lspconfig.nvim" },
    { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
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

    -- Language-specific
    { "mrcjkb/rustaceanvim" },
    { "mfussenegger/nvim-jdtls", lazy = true },
    { "folke/neodev.nvim" }, -- EOL, see https://github.com/folke/lazydev.nvim
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install && git restore .",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        config = function()
            vim.keymap.set("n", "<leader>p", "<cmd>MarkdownPreviewToggle<cr>")
        end,
        ft = { "markdown" }
    }

}

return list
