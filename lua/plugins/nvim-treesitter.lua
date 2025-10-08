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

-- `nvim-treesitter.lua`: `nvim-treesitter/nvim-treesitter` configuration.

--- @require "lazy"

local M = {}

--- @param list string[] List of parsers to always have installed. List with `:TSInstallInfo`.
--- @return LazyPluginSpec
function M.with_ensure_installed(list)
    return {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("register_treesitter", { clear = false }),
                desc = "register Tree-sitter features in new buffers",
                callback = function(args)
                    -- If a parser doesn't exist for this filetype, don't try to register it.
                    if not pcall(vim.treesitter.start) then
                        return
                    end

                    -- This probably assumes that every parser can do folding and indenting, which
                    -- is not true.
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                end
            })

            require("nvim-treesitter").install(list)

            -- Register the Caddyfile parser for the `caddyfile` filetype in addition to the `caddy`
            -- filetype.
            --
            -- See the relevant comment in `/lua/config/filetype.lua` for more details.
            vim.treesitter.language.register("caddy", "caddyfile")
        end
    }
end

return M
