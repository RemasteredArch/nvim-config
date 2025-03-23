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

-- `format.lua`: formatter configurations. Intended to be called by `packages.lua`.

local module = {}

--- Appends the contents of each list onto the first.
---
--- Can handle `nil` values.
---
--- @param lists any[][]
--- @return any[]
local function merge_lists(lists)
    local first_list
    while first_list == nil and #lists ~= 0 do
        first_list = table.remove(lists, 1)
    end

    for _, list in ipairs(lists) do
        for _, v in ipairs(list) do
            table.insert(first_list, v)
        end
    end

    return first_list
end

--- Use `merge_lists` to merge the keys of a list of tables.
---
--- Can handle `nil` values.
---
--- @param tables table<any, any[]>[]
local function merge_lists_tbl(tables)
    local first_table
    while first_table == nil and #tables ~= 0 do
        first_table = table.remove(tables, 1)
    end

    for _, tbl in ipairs(tables) do
        for k, v in pairs(tbl) do
            first_table[k] = merge_lists({ first_table[k], v })
        end
    end

    return first_table
end

function module.setup(formatters_by_ft)
    local prettier_overrides = {
        markdown = { "prettier" },
        yaml = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" }
    }

    local formatters_by_ft = merge_lists_tbl({ prettier_overrides, formatters_by_ft })
    for _, list in pairs(formatters_by_ft) do
        list.stop_after_first = true
    end

    formatters_by_ft.caddyfile = { "caddy_fmt" }

    require("conform").setup({
        formatters = {
            yamlfmt = {
                --- https://github.com/google/yamlfmt/blob/main/docs/config-file.md#basic-formatter
                prepend_args = {
                    "-formatter",
                    "indent=4,line_ending=lf,retain_line_breaks_single=true"
                }
            },
            caddy_fmt = {
                command = "caddy",
                args = { "fmt", "-" }
            }
        },
        formatters_by_ft = formatters_by_ft,
        format_on_save = {} -- Enables formatting on save with default options
    })
end

return module
