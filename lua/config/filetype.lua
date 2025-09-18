--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2025 RemasteredArch

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

-- `filetype.lua`: registering filetypes.

local M = {}

--- @type vim.filetype.add.filetypes
M.filetypes = {
    filename = {
        [".sqruff"] = "ini",
        -- There is an existing pull request to add this filetype:
        --
        -- <https://github.com/vim/vim/pull/16525>
        --
        -- This uses the same name as the filetype added by that pull request. However, the parser
        -- from `nvim-treesitter` (written and added by the same author as that pull request)
        -- expects the `caddy` filetype, so there's a line in `/lua/plugins/nvim-treesitter.lua` to
        -- also register that parser for the `caddyfile` filetype.
        ["Caddyfile"] = "caddyfile",
    }
}

function M.setup()
    vim.filetype.add(M.filetypes)
end

return M
