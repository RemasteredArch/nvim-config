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

function module.set(colorscheme)
  local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme) -- This will always return true, is there a better way to do this?

  if not ok then
    print("colorscheme " .. colorscheme .. " was not found!")
    return
  end
end

function module.setup()
  vim.opt.termguicolors = true   -- True color
  vim.opt.background = "dark"
  module.set("slate")            -- Fallback default value
  module.set("catppuccin-mocha") -- Desired value
end

return module
