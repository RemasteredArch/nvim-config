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

--- Return a map of command names and their callbacks.
---
--- @param client vim.lsp.Client The Tinymist client to execute commands against
--- @param buffnr integer The buffer to register the commands in
--- @return table<string, { callback: fun(), description: string }>
local function create_commands(client, buffnr)
    return {
        TypstPinMain = {
            callback = function()
                client:exec_cmd(
                    {
                        title = "pin main",
                        command = "tinymist.pinMain",
                        arguments = {
                            vim.api.nvim_buf_get_name(buffnr) -- The buffer's full filename.
                        }
                    },
                    { bufnr = buffnr }
                )
            end,
            description = "Mark a file as the main file in a multi-file Typst project"
        },
        TypstUnpinMain = {
            callback = function()
                client:exec_cmd(
                    {
                        title = "unpin main",
                        command = "tinymist.pinMain",
                        arguments = { vim.v.null }
                    },
                    { bufnr = buffnr }
                )
            end,
            description = "Stop marking a file as the main file in a multi-file Typst project"
        }
    }
end

--- Register the commands provided by `create_commands`.
---
--- @param client vim.lsp.Client The Tinymist client to execute commands against
--- @param buffnr integer The buffer to register the commands in
local function register_user_commands(client, buffnr)
    for name, command in pairs(create_commands(client, buffnr)) do
        vim.api.nvim_buf_create_user_command(
            buffnr,
            name,
            command.callback,
            {
                desc = command.description,
                force = true
            }
        )
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Register Tinymist commands",
    group = vim.api.nvim_create_augroup("tinymist_cmds", { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id) or {}
        local buffnr = event.buf

        register_user_commands(client, buffnr)
    end
})

--- @type vim.lsp.Config
return {
    single_file_support = true,
    root_dir = function(buffnr, callback)
        local file = vim.api.nvim_buf_get_name(buffnr)

        local root_dir = require("lspconfig").util.root_pattern("typst.toml", ".git")(file)
            or require("util.files").get_parent_directory(file)

        callback(root_dir)
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
