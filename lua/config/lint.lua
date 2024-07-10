--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- lint.lua: linter configurations. Intended to be called by packages.lua

local module = {}

function module.setup(linters_by_ft)
  require("lint").linters_by_ft = linters_by_ft

  local filetypes_with_linters = {}
  for filetype in pairs(linters_by_ft) do
    table.insert(filetypes_with_linters, filetype)
  end

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint() -- Runs based on linters_by_ft
    end,
  })
end

return module
