--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024-2025 RemasteredArch

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

-- `typst.lua`: configurations for Typst editing
-- <https://typst.app/>

-- Tinymist formats it to this and I don't really feel like fixing that.
--
-- It might also just be built into Typst, I'm not sure.
require("config.options").spaces(2, true)

require("config.keymap").typst().setup()

vim.api.nvim_buf_create_user_command(
    vim.api.nvim_get_current_buf(),
    "SubstituteAll",
    function(opts)
        local range = ""

        -- `opts` is guaranteed to have the following, no need for a null check.
        --
        -- See `:help lua-guide-commands-create` or `:help nvim_create_user_command()`.
        if opts.range == 2 then
            range = opts.line1 .. "," .. opts.line2
        end

        -- `opts` is guaranteed to have the following, no need for a null check.
        for _, substitution in ipairs(opts.fargs) do
            -- `e` suppresses E486 "Pattern not found" from unmatched substitutions.
            --
            -- See `:help s_e`.
            vim.cmd(range .. substitution .. "e")
        end
    end,
    {
        desc = "Replace a series of patterns with values",
        force = true,
        range = true,
        -- Ideally, we'd use `1`, which indicates that it needs exactly one argument, which can
        -- include spaces. This would allow for our own parsing. Unfortunately, I don't have the time
        -- to do string parsing in Lua. Escape your whitespace for now, I guess.
        nargs = "+"
    }
)
