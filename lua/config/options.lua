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

-- options.lua: general options

local module = {}

local opt = vim.opt -- ?? how different from vim.g?

--- Sets Neovim to use spaces instead of tabs.
---
--- @param number_of_spaces integer?
function module.spaces(number_of_spaces)
  opt.tabstop = 8 -- Number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = true
  opt.shiftwidth = number_of_spaces or 2
end

--- Sets Neovim to use tabs instead of spaces.
---
--- @param tab_render_length integer?
function module.tabs(tab_render_length)
  opt.tabstop = tab_render_length or 2 -- Number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = false
  opt.shiftwidth = 0 -- Uses `tabstop` when 0
end

function module.setup()
  -- Global options
  vim.g.mapleader = " " -- Sets starting key for custom keybinds

  -- Current line behavior
  opt.cursorline = true     -- Highlights the current line
  opt.number = true         -- Sets line numbers
  opt.relativenumber = true -- Sets line numbering as relative to current line

  -- Wrap lines on whitespace, etc. instead of at the last character that fits
  opt.linebreak = true

  module.spaces()
end

return module
