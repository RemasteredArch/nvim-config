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

-- `lazydev.lua`: `folke/lazydev.nvim` configuration.

return {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    dependencies = {
        {
            "DrKJeff16/wezterm-types",
            lazy = true
        }
    },
    opts = {
        library = {
            -- Load Luvit types when `vim.uv` is found in a line of code in the file.
            --
            -- See `:h vim.uv`.
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },

            -- Load WezTerm types when a file includes `require("wezterm")`.
            --
            -- Comes from <https://github.com/justinsgithub/wezterm-types> or the more up-to-date
            -- <https://github.com/gonstoll/wezterm-types>.
            { path = "wezterm-types", mods = { "wezterm" } }
        }
    }
}
