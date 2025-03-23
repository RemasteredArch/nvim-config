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

-- `color_scheme.lua`: settings and helpers for color schemes.

local module = {}

module.scheme = {
    light = "catppuccin-latte",
    dark = "catppuccin-mocha",
    fallback = "slate"
}

--- Sets a given color scheme.
---
--- A `vim.cmd.colorscheme(color_scheme)` wrapper with better errors.
---
--- @param color_scheme string The color scheme to set
--- @param silent boolean? Whether or not to throw an error
--- @return boolean # Exit code; `true` indicates success
function module.set(color_scheme, silent)
    if not pcall(vim.cmd.colorscheme, color_scheme) then
        if not silent then
            vim.api.nvim_err_writeln("Color scheme '" .. color_scheme .. "' was not found!")
        end

        return false
    end

    return true
end

--- Setup color schemes.
---
--- @param opts { use_light_mode: boolean?, silent: boolean? }?
--- @return boolean # Exit code, true = success
function module.setup(opts)
    vim.api.nvim_create_user_command(
        "ColorSchemeToggle",
        module.toggle_light_dark,
        { force = true }
    )


    local opts = opts or {}
    local use_light_mode = opts.use_light_mode
    local silent = opts.silent

    --- @type "dark" | "light"
    local background = "dark"
    local color_scheme = module.scheme.dark

    if use_light_mode then
        background = "light"
        color_scheme = module.scheme.light
    end

    vim.opt.termguicolors = true -- True color
    vim.opt.background = background

    return module.set(module.scheme.fallback, silent) -- Fallback default value.
        and module.set(color_scheme, silent)          -- Preferred value.
end

--- Toggle between light and dark for the background and color_scheme.
function module.toggle_light_dark()
    --- @type "dark" | "light"
    local background = "dark"
    local color_scheme = module.scheme.dark

    --- @diagnostic disable-next-line: undefined-field This is actually defined, see |vim.opt:get()|.
    if vim.opt.background:get() == "dark" then
        background = "light"
        color_scheme = module.scheme.light
    end

    vim.opt.background = background
    module.set(color_scheme)
end

return module
