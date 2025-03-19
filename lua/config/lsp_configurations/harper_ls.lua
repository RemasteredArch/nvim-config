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

-- `harper_ls.lua`: LSP configurations for Harper, a spelling and grammar checker.

--- Harper is necessarily pretty aggressive, this returns a callback to toggle it when it gets too
--- loud.
---
--- It will detach and reattach Harper (or any other given LSP client) from the given buffer, with
--- the intention of disabling their diagnostics.
---
--- @param client vim.lsp.Client The LSP client being toggled.
--- @param buffnr integer The buffer to attach and detach the client from.
--- @return fun() callback The callback that actually toggles the client.
local function toggle_callback(client, buffnr)
    return function()
        if client.attached_buffers[buffnr] then
            vim.lsp.buf_detach_client(buffnr, client.id)
        else
            vim.lsp.buf_attach_client(buffnr, client.id)
        end
    end
end

--- @type vim.lsp.Config
return {
    settings = {
        ["harper-ls"] = {
            linters = {
                LongSentences = false
            }
        }
    },

    on_attach = function(client, buffnr)
        vim.api.nvim_buf_create_user_command(
            buffnr,
            "HarperToggle",
            toggle_callback(client, buffnr),
            {
                desc = "Toggle diagnostics from Harper by attaching/detaching it from the buffer",
                force = true
            }
        )
    end
}
