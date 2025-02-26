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

-- `harper_ls.lua`: LSP configurations for Harper, a spelling and grammar checker

return {
    settings = {
        ["harper-ls"] = {
            linters = {
                LongSentences = false
            }
        }
    },

    commands = {
        --- Harper is necessarily pretty aggressive, here's something to toggle it when it gets too
        --- loud
        HarperToggle = {
            function()
                local filter = { name = "harper_ls" } --- @type vim.lsp.get_clients.Filter
                local client = vim.lsp.get_clients(filter)[1]

                local current_buffer = vim.api.nvim_get_current_buf()

                -- If it is attached to the current buffer
                if client.attached_buffers[current_buffer] then
                    vim.lsp.buf_detach_client(current_buffer, client.id)
                else
                    vim.lsp.buf_attach_client(current_buffer, client.id)
                end
            end,
            description = "Toggle harper_ls"
        }
    }
}
