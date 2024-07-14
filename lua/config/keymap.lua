--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- keymap.lua: various key mappings

local module = {}

-- Sets a key mapping
local function set(mode, key, result, opts)
  vim.keymap.set(mode, key, result, opts)
end

module.set = set -- Lets functions in keymap.lua use set(...) instead of module.set(...)


-- Key mappings for nvim-cmp
function module.cmp()
  -- local cmp_action = require("lsp-zero").cmp_action() -- A few helper actions
  local cmp = require("cmp")

  return {
    ["<Tab>"] = cmp.mapping.confirm({ select = true })
  }
end

return module
