--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024-2025 RemasteredArch

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

-- `options.lua`: general Neovim options.

local module = {}

--- The default number of spaces.
---
--- Used either for indentation width (when using tabs) or indent rendering width (when using
--- tabs).
---
--- @type integer
local default_spaces = 4

--- Sets Neovim to use spaces instead of tabs.
---
--- @param number_of_spaces integer?
--- @param register_locally boolean? Whether to register these options locally (`true`) or globally (`false` or `nil`)
function module.spaces(number_of_spaces, register_locally)
    local opt = vim.opt
    if register_locally then
        opt = vim.opt_local
    end

    -- Width in columns that tab characters render as.
    opt.tabstop = 8
    opt.softtabstop = 0
    opt.expandtab = true
    opt.shiftwidth = number_of_spaces or default_spaces
end

--- Sets Neovim to use tabs instead of spaces.
---
--- @param tab_render_length integer?
--- @param register_locally boolean? Whether to register these options locally (`true`) or globally (`false` or `nil`)
function module.tabs(tab_render_length, register_locally)
    local opt = vim.opt
    if register_locally then
        opt = vim.opt_local
    end

    -- Width in columns that tab characters render as.
    opt.tabstop = tab_render_length or default_spaces
    opt.softtabstop = 0
    opt.expandtab = false
    opt.shiftwidth = 0 -- Uses `tabstop` when 0
end

--- @param register_locally boolean? Whether to register these options locally (`true`) or globally (`false` or `nil`)
function module.setup(register_locally)
    local opt = vim.opt
    if register_locally then
        opt = vim.opt_local
    end

    -- Global options
    vim.g.mapleader = " " -- Sets starting key for custom keybinds.

    -- Current line behavior
    opt.cursorline = true     -- Highlights the current line.
    opt.number = true         -- Sets line numbers.
    opt.relativenumber = true -- Sets line numbering as relative to current line.

    -- Wrap lines on whitespace, etc. instead of at the last character that fits.
    opt.linebreak = true

    module.spaces(nil, register_locally)
end

return module
