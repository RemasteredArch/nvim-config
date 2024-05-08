--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

--[ OPTIONS ]--

-- global options
vim.g.mapleader = " " -- sets starting key for custom keybinds

local opt = vim.opt   -- ?? how different from vim.g?

-- current line behavior
opt.cursorline = true     -- highlights the current line
opt.number = true         -- sets line numbers
opt.relativenumber = true -- sets line numbering as relative to current line

-- spaces instead of tabs
local function spaces()
  opt.tabstop = 8 -- number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = true
  opt.shiftwidth = 2
end

-- tabs instead of spaces
local function tabs()
  opt.tabstop = 2 -- number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = false
  opt.shiftwidth = 2
end

spaces()

-- wrap lines on whitespace, etc instead of at the last character that fits
opt.linebreak = true

-- colors
opt.termguicolors = true                                      -- enables coloring
opt.background = "dark"
function SetColorscheme(colorscheme)                          -- allows setting colorscheme to fail loudly... vim.cmd.colorscheme = "whatever" will fail silently
  local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme) -- this will always return true, is there a better way to do this?

  if not ok then
    print("colorscheme " .. colorscheme .. " was not found!")
    return
  end
end

SetColorscheme("slate") -- set colorscheme using a built-in as a fallback

--[ PLUGINS ]--

local packages = {
  treesitter = {
    "c", "lua", "vim", "vimdoc", "query", "javascript", "html", "css", "rust", "java", "bash", "markdown", "toml", "json",
    "jsonc", "xml", "cpp", "cmake", "regex", "markdown_inline"
  },
  mason = {
    linter = {
      text = { "vale" },
      markdown = { "vale" }
      -- json = { "jsonlint" }
    },
    lsp = {
      "jdtls",    -- java, see also see ftplugin/java.lua
      "bashls",   -- integrates with shellcheck
      "lua_ls",
      "marksman", -- markdown
      "gradle_ls",
      "taplo",    -- toml
      "biome",    -- ts, js, jsx, json, jsonc, etc.
      "lemminx",  -- xml
      -- "rust_analyzer", -- install with `rustup compent add rust-analyzer` instead where possible
      "clangd",
      "neocmake",
      "vale_ls"
    },
    other = {
      "shellcheck",
      "shfmt"
    },
  },
  print_all = function(self)
    local function print_table(tbl)
      local str = "{ "

      for k, v in pairs(tbl) do
        if type(v) == "string" then
          if type(k) == "number" then
            str = ("%s%s, "):format(str, v)
          else
            str = ("%s%s: %s, "):format(str, k, v)
          end
        elseif type(v) == "table" then
          str = ("%s%s: %s, "):format(str, k, print_table(v))
        end
      end

      return str .. "}"
    end

    for k, v in pairs(self) do
      if type(v) == "table" then
        local str = print_table(v)
        print(string.format("%s: %s\n\n", k, str))
      end
    end
  end,
  get_all = function(input_table)
    local index = 1
    local array = {}

    local function recurse_table(table)
      for _, v in pairs(table) do
        if type(v) == "string" then
          array[index] = v
          index = index + 1
        elseif type(v) == "table" then
          recurse_table(v)
        end
      end
    end

    recurse_table(input_table)
    return array
  end
}

local function array_to_string(arr, column_count, column_width)
  if type(column_width) == "nil" then
    column_width = 0 -- string.format will allow overflow
  end

  local index = 1
  local str = "{ "

  local separator = ", "
  if type(column_count) ~= "nil" then
    separator = separator .. "  "
  end

  for _, v in ipairs(arr) do
    if type(column_count) ~= "nil" and index % column_count == 1 then
      str = str .. "\n  "
    end

    str = ("%s%-" .. column_width + separator:len() .. "s"):format(str, v .. separator)

    index = index + 1
  end

  if type(column_count) ~= "nil" then
    str = str .. "\n"
  end

  return str .. "}"
end

print('# "Pretty" printed:')
packages:print_all()

print("# Only Treesitter parsers:")
print(array_to_string(packages.get_all(packages.treesitter), 3, 15))
print("\n# Only mason.nvim packages:")
print(array_to_string(packages.get_all(packages.mason), 3, 15))

-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        -- list of parsers to always have installed, the first 5 are required
        -- List with :TSInstallInfo
        ensure_installed = packages.treesitter,
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
        }
      })
    end
  },

  -- color scheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
  },

  -- code screenshots
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    config = function()
      local output_path = vim.fn.stdpath("data") .. "/silicon"

      if vim.fn.isdirectory(output_path) == 0 then
        vim.fn.mkdir(output_path)
      end

      require("silicon").setup({
        font = "CaskaydiaCove Nerd Font=34;Noto Color Emoji=34",
        tab_width = 2,
        theme = "OneHalfDark", -- `silicon --list-themes` (also nice: "Visual Studio Dark+")
        line_offset = function(args)
          return args.line1
        end,
        output = function()
          return output_path .. "/" .. vim.fn.expand("%:t") .. ".silicon.png"
        end,
        window_title = function()
          return vim.fn.expand("%:t")
        end
      })
    end
  },
  {
    "ziontee113/icon-picker.nvim",
    lazy = true,
    config = function()
      require("icon-picker").setup({ disable_legacy_commands = true })
    end
  },

  -- UI
  {
    "stevearc/dressing.nvim",
    -- opts = {} -- e.g. insert_only = true by default
  },

  --[[{
    "folke/noice.nvim", -- temporarily disabled, causes a crash
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },]]

  -- Package management
  { "williamboman/mason.nvim" },
  { "rshkarin/mason-nvim-lint" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },

  -- Linters
  { "mfussenegger/nvim-lint" },

  -- LSP/DAP
  { "williamboman/mason-lspconfig.nvim" },
  { "VonHeikemen/lsp-zero.nvim",                branch = "v3.x" },
  { "mfussenegger/nvim-jdtls" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/nvim-cmp" },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "kmarius/jsregexp" -- does not get recognized?
    }
  },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "mrcjkb/rustaceanvim" },

})

-- colorscheme
SetColorscheme("catppuccin-mocha")

-- UI
--[[require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    }
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    lsp_doc_border = true
  }
})]]

--[ General package management ]--

require("mason").setup()

--[ Linters ]--
require("lint").linters_by_ft = packages.mason.linter

-- Can install more than linters
require("mason-nvim-lint").setup({
  ensure_installed = packages.mason.other
})

local function install_all()
  require("mason-nvim-lint").auto_install()
end

vim.api.nvim_create_user_command(
  "MasonInstallAll",
  function()
    require("mason-tool-installer").check_install(true, true)
  end,
  { force = true }
)


--[ LSPs ]--
local lsp_zero = require("lsp-zero")

-- lspzero https://lsp-zero.netlify.app/v3.x/getting-started.html

lsp_zero.on_attach(function(client, buffnr)
  -- :help lsp-zero-keybindings
  lsp_zero.default_keymaps({ buffer = buffnr })
  lsp_zero.buffer_autoformat()
end)

-- for more on mason + lspzero:
-- https://lsp-zero.netlify.app/v3.x/guide/integrate-with-mason-nvim.html
require("mason-lspconfig").setup({
  ensure_installed = packages.mason.lsp,
  automatic_installation = false,
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
    lua_ls = function()
      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                "vim"
              }
            },
            format = {
              defaultConfig = { -- doesn't work. why?
                -- used as prescribed by https://luals.github.io/wiki/settings/
                -- options drawn from https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
                align_call_args = false,
                align_function_params = false,
                align_continuous_assign_statement = false,
                align_continuous_rect_table_field = false,
                align_if_branch = false,
                align_array_table = false
                -- additional options from https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/lua.template.editorconfig
                -- align_continuous_line_space = <num>
                -- align_continuous_similar_call_args = false
                -- align_continuous_inline_comment = false
              }
            }
          }
        }
      })
    end,
    rust_analyzer = lsp_zero.noop
  }
})

vim.g.rustaceanvim = {
  -- tools = {}, -- plugins
  server = { -- lsp
    capabilities = lsp_zero.get_capabilities()
  }
  -- dap = {}
}


--[[
-- Automatically set unusual filetypes
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = {*.extension},
	command = "set filetype=lang"
}
]]

-- spiders🕷️🕸️
