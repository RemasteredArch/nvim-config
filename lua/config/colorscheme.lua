--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- colorscheme.lua: settings and helpers for colorschemes

local module = {}

--- Sets a given colorscheme.
---
--- A `vim.cmd.colorscheme(colorscheme)` wrapper with better errors.
---
--- @param colorscheme string The colorscheme to set
--- @param silent boolean? Whether or not to throw an error
--- @return boolean # Exit code, true = sucess
function module.set(colorscheme, silent)
  if not pcall(vim.cmd.colorscheme, colorscheme) then
    if not silent then
      vim.api.nvim_err_writeln("Colorscheme '" .. colorscheme .. "' was not found!")
    end

    return false
  end

  return true
end

--- Setup colorschemes.
---
--- @param opts { use_light_mode: boolean?, silent: boolean? }?
--- @return boolean # Exit code, true = sucess
function module.setup(opts)
  local opts = opts or {}
  local use_light_mode = opts.use_light_mode
  local silent = opts.silent

  --- @type "dark" | "light"
  local background = "dark"
  local colorscheme = "catppuccin-mocha"

  if use_light_mode then
    background = "light"
    colorscheme = "catppuccin-latte"
  end

  vim.opt.termguicolors = true -- True color
  vim.opt.background = background

  return module.set("slate", silent)      -- Fallback default value
      and module.set(colorscheme, silent) -- Preferred value
end

return module
