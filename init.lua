--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

--[ OPTIONS ]--

require("config.options").setup()

--[ PLUGINS ]--

local packages = require("config.packages")

-- Lazy.nvim
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
  rocks = { -- Disable luarocks
    enabled = false
  },
  spec = packages.list.lazy
})

--[ Colorscheme ]--
require("config.colorscheme").setup()

--[ General package management ]--

require("mason").setup()

--[ Linters ]--
require("lint").linters_by_ft = packages.list.mason.linter

-- Can install more than linters
require("mason-nvim-lint").setup({
  ensure_installed = packages.list.mason.other
})

vim.api.nvim_create_user_command(
  "MasonInstallAll",
  packages.install.mason,
  { force = true }
)

vim.api.nvim_create_user_command(
  "TSInstallAll",
  packages.install.treesitter,
  { force = true }
)

--[ LSPs ]--

local lsp_zero = require("lsp-zero")

-- lspzero https://lsp-zero.netlify.app/v3.x/getting-started.html

lsp_zero.on_attach(function(client, buffnr)
  -- :help lsp-zero-keybindings
  lsp_zero.default_keymaps({ buffer = buffnr })

  if client.name ~= "vtsls" then
    lsp_zero.buffer_autoformat()
  end
end)

-- Neovim-specific additions to lua_ls
require("neodev").setup()

-- for more on mason + lspzero:
-- https://lsp-zero.netlify.app/v3.x/guide/integrate-with-mason-nvim.html
require("mason-lspconfig").setup({
  ensure_installed = packages.list.mason.lsp,
  automatic_installation = false,
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
    rust_analyzer = lsp_zero.noop,
  }
})
require("lspconfig").biome.setup({})
-- root_dir = require("lspconfig").util.root_pattern("biome.json", "biome.jsonc", "tsconfig.json", "package.json")

vim.g.rustaceanvim = {
  -- tools = {}, -- plugins
  server = { -- lsp
    capabilities = lsp_zero.get_capabilities()
  }
  -- dap = {}
}

-- spiders🕷️🕸️
