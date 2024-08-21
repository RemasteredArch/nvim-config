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

-- lsp.lua: LSP (language server protocol) implementation configuration

local module = {}

function module.setup(packages)
    local lsp_zero = require("lsp-zero")

    -- lspzero https://lsp-zero.netlify.app/v3.x/getting-started.html

    lsp_zero.on_attach(function(client, buffnr)
        -- :help lsp-zero-keybindings
        lsp_zero.default_keymaps({ buffer = buffnr })

        if client.name ~= "vtsls" then
            lsp_zero.buffer_autoformat()
        end
    end)

    -- Neovim-specific additions to lua_ls
    require("neodev").setup()

    -- for more on mason + lspzero:
    -- https://lsp-zero.netlify.app/v3.x/guide/integrate-with-mason-nvim.html
    require("mason-lspconfig").setup({
        ensure_installed = packages.list.mason.lsp,
        automatic_installation = false,
        handlers = {
            lsp_zero.default_setup,
            jdtls = lsp_zero.noop,
            rust_analyzer = lsp_zero.noop
        }
    })
    require("lspconfig").biome.setup({})
    require("lspconfig").html.setup({
        settings = {
            -- For all options see:
            -- https://code.visualstudio.com/docs/getstarted/settings
            -- With explanations:
            -- https://code.visualstudio.com/Docs/languages/html
            html = {
                format = {
                    maxPreserveNewLines = "1", -- Don't allow multiple successive line breaks
                    wrapLineLength = "100"
                }
            }
        }
    })

    require("lspconfig").lua_ls.setup({
        settings = {
            --- Configurations for Lua Language Server
            ---
            --- [Docs](https://luals.github.io/wiki/settings/)
            ---
            --- @type table<string, table>
            Lua = {
                --- Formatter settings.
                format = {
                    --- Default configurations for EmmyLuaCodeStyle.
                    ---
                    --- Will be overridden by a `.luarc.json`.
                    ---
                    --- @type table<string, string | boolean>
                    ---
                    --- [Docs](https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md)
                    defaultConfig = {
                        --- Max columns in a line.
                        ---
                        --- Default: `"120"`
                        max_line_length = "100",

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
                        --- Default: `true`
                        align_function_params = false,

                        --- Indent parameters to align when function calls wrap.
                        ---
                        --- Default: `false`
                        align_call_args = false,

                        --- When assigning to values over multiple lines (ignoring comments),
                        --- indent the `=` to align the values.
                        ---
                        --- Default: `true`
                        align_continuous_assign_statement = false,

                        --- When assigning keys with values in tables, indent the `=` to align the
                        --- values.
                        ---
                        --- Default: `true`
                        align_continuous_rect_table_field = false,

                        --- Align the branches of `if` statements. Includes branches starting with
                        --- `or` and `and`.
                        ---
                        --- Default: `true`
                        align_if_branch = false,

                        --- Align items in arrays.
                        ---
                        --- Default: `true`
                        align_array_table = false,

                        --- When an array table is long enough to wrap, give each entry its own
                        --- line.
                        ---
                        --- Default: `false`
                        break_all_list_when_line_exceed = true
                    }
                }
            }
        }
    })

    vim.g.rustaceanvim = {
        -- tools = {}, -- plugins
        server = { -- lsp
            capabilities = lsp_zero.get_capabilities()
        }
        -- dap = {}
    }
end

return module
