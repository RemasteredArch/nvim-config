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

-- `lsp.lua`: LSP (language server protocol) implementation configuration

local module = {}

--- Enable format on write for an LSP in a buffer.
---
--- Modified from lsp-zero. Copyright (c) 2024 Heiker Curiel, MIT license.
---
--- - <https://lsp-zero.netlify.app/docs/language-server-configuration.html#enable-format-on-save>
--- - <https://github.com/VonHeikemen/lsp-zero.nvim/blob/35421bd/lua/lsp-zero/format.lua#L117-L166>
--- - <https://github.com/VonHeikemen/lsp-zero.nvim/blob/35421bd/LICENSE>
---
--- @param buffnr integer The buffer ID to register the formatting autocmd in.
--- @param client vim.lsp.Client The LSP client to register formatting for.
local function autofmt(buffnr, client)
    local group = "autofmt"

    client = client or {}
    buffnr = buffnr or vim.api.nvim_get_current_buf()

    vim.api.nvim_create_augroup(group, { clear = false })
    vim.api.nvim_clear_autocmds({ group = group, buffer = buffnr })

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = buffnr,
        desc = "Format on write",
        callback = function()
            vim.lsp.buf.format({
                bufnr = buffnr,
                async = false,
                timeout_ms = 10 * 1000,
                id = client.id,
                name = client.name
            })
        end
    })
end

function module.setup(packages)
    local lsp_zero = require("lsp-zero")

    -- lsp-zero setup
    --
    -- <https://lsp-zero.netlify.app/docs/getting-started.html>
    lsp_zero.extend_lspconfig({
        lsp_attach = function(client, buffnr)
            require("config.keymap").lsp().setup(buffnr)

            if client.name ~= "vtsls" then
                autofmt(buffnr, client)
            end
        end,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        float_border = "rounded",
        sign_text = true
    })

    -- Neovim-specific additions to `lua_ls`
    require("neodev").setup()

    --- Setup an LSP using `nvim-lspconfig`.
    ---
    --- @param lsp string An LSP server's name
    local function setup_lsp(lsp)
        local success, config = pcall(require, "config.lsp_configurations." .. lsp)
        if not success then config = {} end -- Default to empty table

        require("lspconfig")[lsp].setup(config)
    end

    --- Dummy function to avoid configuring an LSP.
    ---
    --- Usually done so that another plugin can handle it.
    local function no_config() end

    -- For more on Mason + lsp-zero:
    --
    -- <https://lsp-zero.netlify.app/docs/guide/integrate-with-mason-nvim.html>
    require("mason-lspconfig").setup({
        ensure_installed = packages.list.mason.lsp,
        automatic_installation = false,
        handlers = {
            -- Default
            function(server_name)
                require("lspconfig")[server_name].setup({})
            end,
            -- Handled by other plugins
            jdtls = no_config,
            rust_analyzer = no_config,
            -- Custom configuration file
            lua_ls = setup_lsp,
            html = setup_lsp,
            cssls = setup_lsp,
            harper_ls = setup_lsp,
            yamlls = setup_lsp,
            tinymist = setup_lsp
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
