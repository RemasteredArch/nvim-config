--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- package_list.lua: lists of all Treesitter, Mason, and Lazy packages, intended only for use in packages.lua

local list = {
  treesitter = {
    "c", "lua", "vim", "vimdoc", "query", "javascript", "typescript", "html", "css", "rust", "java", "bash", "markdown",
    "toml", "json", "jsonc", "xml", "cpp", "cmake", "regex", "markdown_inline", "tmux", "python"
  },
  lazy = {}, -- Defined below
  mason = {
    linter = {
      text = { "vale" },
      markdown = { "vale" },
      help = { "vale" }
      -- json = { "jsonlint" }
    },
    lsp = {
      "jdtls",    -- java, see also see ftplugin/java.lua
      "bashls",   -- integrates with shellcheck
      "lua_ls",
      "marksman", -- markdown
      "gradle_ls",
      "taplo",    -- toml
      "biome",    -- js, ts, jsx, json, jsonc, etc.
      "vtsls",    -- js, ts, jsx, react
      "lemminx",  -- xml
      -- "rust_analyzer", -- install with `rustup compent add rust-analyzer` instead where possible
      "clangd",
      "neocmake",
    },
    dap = {
      "codelldb"
    },
    other = {
      "shellcheck"
    }
  },
}

list.lazy = {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      ---@diagnostic disable-next-line:missing-fields
      configs.setup({
        -- list of parsers to always have installed, the first 5 are required
        -- List with :TSInstallInfo
        ensure_installed = list.treesitter,
        -- install the above ensured parsers synchronously
        sync_install = false,

        highlight = {
          enable = true,
          --[[-- disables syntax highlighting for overly large files
          disable = function(lang, buf)
            local maxFilesize = 100 * 1024 -- 100 KiB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats > maxFilesize then
              return true
            end
          end,]]
          additional_vim_regex_highlighting = false
        },
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
          title = " substitute with ripgrep",
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
    "stevearc/dressing.nvim",
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
    end,
  },

  -- Package management
  { "williamboman/mason.nvim" },
  { "rshkarin/mason-nvim-lint" },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true
  },

  -- Linters
  { "mfussenegger/nvim-lint" },

  -- LSP/DAP
  { "williamboman/mason-lspconfig.nvim" },
  { "VonHeikemen/lsp-zero.nvim",        branch = "v3.x" },
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
  { "folke/neodev.nvim" } -- EOL, see https://github.com/folke/lazydev.nvim
}

return list
