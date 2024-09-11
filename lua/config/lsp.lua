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

    --- Setup an LSP using nvim-lspconfig.
    ---
    --- @param lsp string An LSP server's name
    local function setup_lsp(lsp)
        local success, config = pcall(require, "config.lsp_configurations." .. lsp)
        if not success then config = {} end -- Default to empty table

        require("lspconfig")[lsp].setup(config)
    end

    vim.tbl_map(setup_lsp, { "lua_ls", "html", "biome", "harper_ls", "yamlls" })


    vim.g.rustaceanvim = {
        -- tools = {}, -- plugins
        server = { -- lsp
            capabilities = lsp_zero.get_capabilities()
        }
        -- dap = {}
    }
end

return module
