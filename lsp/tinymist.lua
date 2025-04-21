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
            or require("util.files").get_parent_directory(file)
    end,
    settings = {
        --- Enables a built-in formatter.
        ---
        --- Default `"disable"`.
        ---
        --- @type "typstyle" | "typstfmt" | "disable"
        formatterMode = "typstyle"
    },
    commands = {
        TypstPinMain = {
            function()
                vim.lsp.buf.execute_command({
                    command = "tinymist.pinMain",
                    arguments = {
                        vim.api.nvim_buf_get_name(0) -- Current buffer's full file name.
                    }
                })
            end,
            description = "Mark a file as the main file in a multi-file Typst project"
        },
        TypstUnpinMain = {
            function()
                vim.lsp.buf.execute_command({
                    command = "tinymist.pinMain",
                    -- Setting to `nil` is supposed to remove the pin, but it seems to just trigger
                    -- an error instead.
                    arguments = { nil }
                })
            end,
            description = "Stop marking a file as the main file in a multi-file Typst project"
        }
    }
}
