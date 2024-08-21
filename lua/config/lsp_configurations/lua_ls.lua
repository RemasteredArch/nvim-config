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

--- @alias BoolStr "true" | "false" A boolean, represented as a string.

return {
    settings = {
        --- Configurations for Lua Language Server
        ---
        --- [Docs](https://luals.github.io/wiki/settings/)
        ---
        --- @type table<string, table>
        ---
        --- Default: `{}`
        Lua = {
            --- Formatter settings.
            format = {
                --- Default configurations for EmmyLuaCodeStyle.
                ---
                --- Will be overridden by a `.luarc.json`.
                ---
                --- @type table<string, string>
                ---
                --- [Docs](https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md)
                defaultConfig = {
                    --- Max columns in a line.
                    ---
                    --- @type string Must be a non-negative integer value in a string.
                    ---
                    --- Default: `"120"`
                    max_line_length = "100",

                    --- Quotation mark character for string literals.
                    ---
                    --- @type
                    --- | "double" Use double quotes: `"`
                    --- | "single" Use single quotes: `'`
                    --- | "none" Keep existing styling
                    ---
                    --- Default: `"none"`
                    quote_style = "double",

                    --- How to handle the last separator in a table.
                    ---
                    --- @type
                    --- | "keep" Keep existing formatting
                    --- | "never" Always remove
                    --- | "always" Always add
                    --- | "smart" Add if multiline, remove if singleline
                    ---
                    --- Default: `"keep"`
                    trailing_table_separator = "never",

                    --- Indent parameters to align when function definitions wrap.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"true"`
                    align_function_params = "false",

                    --- Indent parameters to align when function calls wrap.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"false"`
                    align_call_args = "false",

                    --- When assigning to values over multiple lines (ignoring comments),
                    --- indent the `=` to align the values.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"true"`
                    align_continuous_assign_statement = "false",

                    --- When assigning keys with values in tables, indent the `=` to align the
                    --- values.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"true"`
                    align_continuous_rect_table_field = "false",

                    --- Align the branches of `if` statements. Includes branches starting with
                    --- `or` and `and`.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"true"`
                    align_if_branch = "false",

                    --- Align items in arrays.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"true"`
                    align_array_table = "false",

                    --- When an array table is long enough to wrap, give each entry its own
                    --- line.
                    ---
                    --- @type BoolStr
                    ---
                    --- Default: `"false"`
                    break_all_list_when_line_exceed = "true"
                }
            }
        }
    }
}
