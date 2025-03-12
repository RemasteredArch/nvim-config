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
--- Modified from LSP Zero. Copyright © 2024 Heiker Curiel, MIT license.
---
--- - <https://lsp-zero.netlify.app/docs/language-server-configuration.html#enable-format-on-save>
--- - <https://github.com/VonHeikemen/lsp-zero.nvim/blob/35421bd/lua/lsp-zero/format.lua#L117-L166>
--- - <https://github.com/VonHeikemen/lsp-zero.nvim/blob/35421bd/LICENSE>
---
--- @param buffnr integer The buffer ID to register the formatting autocmd in.
--- @param client vim.lsp.Client The LSP client to register formatting for.
local function enable_autofmt(buffnr, client)
    local group = "autofmt"

    client = client or {}
    buffnr = buffnr or vim.api.nvim_get_current_buf()

    vim.api.nvim_create_augroup(group, { clear = false })
    vim.api.nvim_clear_autocmds({ group = group, buffer = buffnr })

    local desc = "Format on write"
    if client.name then
        desc = string.format("Format on write using %s", client.name)
    end

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = buffnr,
        desc = desc,
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

--- Configure options and enable hooks to properly style LSP-related UIs.
local function config_ui()
    vim.opt.signcolumn = "yes"

    -- This could better integrate with `colors_cheme.lua`.
    local colors = require("catppuccin.palettes.mocha")
    -- Used to set the borders of floating windows to the same color as the background of the
    -- content of the window.
    --
    -- It's possible they're not *always* mantle, but `NormalFloat` does use that,
    -- so completion pop-ups and Lazy.nvim both use it.
    vim.api.nvim_set_hl(0, "CustomFloatBorder", { fg = colors.blue, bg = colors.mantle })

    local original_fn = vim.lsp.util.open_floating_preview
    --- @diagnostic disable-next-line:duplicate-set-field Resetting the field to insert a hook.
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"

        local buffnr, winid = original_fn(contents, syntax, opts, ...)

        -- Override the `FloatBorder` highlight group for this new floating window.
        vim.api.nvim_set_option_value(
            "winhighlight",
            "FloatBorder:CustomFloatBorder",
            { win = winid }
        )

        return buffnr, winid
    end
end

function module.setup(packages)
    local capabilities = require("lspconfig").util.default_config.capabilities
    capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        require("cmp_nvim_lsp").default_capabilities()
    )

    vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP buffer-specific configurations",
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id) or {}
            local buffnr = event.buf

            require("config.keymap").lsp().setup(buffnr)

            if client.name ~= "vtsls" and client:supports_method("textDocument/formatting") then
                enable_autofmt(buffnr, client)
            end
        end
    })

    config_ui()

    --- Setup an LSP using `nvim-lspconfig`.
    ---
    --- @param lsp string An LSP server's name.
    local function setup_lsp(lsp)
        local success, config = pcall(require, "config.lsp_configurations." .. lsp)
        if not success then config = {} end -- Default to empty table

        require("lspconfig")[lsp].setup(config)
    end

    --- Dummy function to avoid configuring an LSP.
    ---
    --- Usually done so that another plugin can handle it.
    local function no_config() end

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
        server = {
            capabilities = capabilities
        }
    }
end

return module
