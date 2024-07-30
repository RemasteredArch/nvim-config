--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- init.lua: initialization file for Neovim, exists primarily to pull from other config files, under lua/config/*.lua

--[ OPTIONS ]--
require("config.options").setup()

--[ Colorscheme ]--
-- Inital setup before package installation
-- Might miss Catppuccin so it is retried later if it fails
local colorscheme_success = require("config.colorscheme").setup({ silent = true })

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
if not colorscheme_success then
  require("config.colorscheme").setup()
end

--[ General package management ]--
packages.setup()

--[ LSPs ]--
require("config.lsp").setup(packages)
require("config.cmp").setup()

--[ DAP ]--
require("config.dap").setup()

-- spiders🕷️🕸️
