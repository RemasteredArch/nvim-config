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

-- `tinymist.lua`: LSP configurations for tinymist, a Typst language server.

return {
    single_file_support = true,
    root_dir = function(file)
        return require("lspconfig").util.root_pattern("typst.toml", ".git")(file)
            or vim.fn.getcwd()
    end,
    settings = {
        --- Enables a built-in formatter.
        ---
        --- Default `"disable"`.
        ---
        --- @type "typstyle" | "typstfmt" | "disable"
        formatterMode = "typstyle"
    }
}
