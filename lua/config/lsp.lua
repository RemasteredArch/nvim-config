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

    buffnr = buffnr or vim.api.nvim_get_current_buf()
    client = client or {}

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

--- Enables format on write if the server indicates support for
--- `textDocument/formatting` with a `client/registerCapability` request to the client.
---
--- <https://microsoft.github.io/language-server-protocol/specifications/specification-current/#client_registerCapability>
local function catch_dynamic_formatting_registration()
    local original_handler = vim.lsp.handlers["client/registerCapability"]

    --- Enables format on write if the server indicates support for
    --- `textDocument/formatting` with a `client/registerCapability` request to the client,
    --- then calls the original handler for `client/RegisterCapability`.
    ---
    --- <https://microsoft.github.io/language-server-protocol/specifications/specification-current/#client_registerCapability>
    ---
    --- @param err lsp.ResponseError? Should be `nil`.
    --- @param params lsp.RegistrationParams
    --- @param context lsp.HandlerContext
    --- @param cfg table? Should be `nil`.
    vim.lsp.handlers["client/registerCapability"] = function(
        err,
        params,
        context,
        cfg
    )
        for _, registration in ipairs(params.registrations) do
            if registration.method == "textDocument/formatting" then
                local client = assert(vim.lsp.get_client_by_id(context.client_id))

                for buffnr in pairs(client.attached_buffers) do
                    enable_autofmt(buffnr, client)
                end

                break
            end
        end

        return original_handler(err, params, context, cfg)
    end
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
    --- @diagnostic disable-next-line: duplicate-set-field Resetting the field to insert a hook.
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

    vim.lsp.config("*", {
        capabilities = capabilities
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP buffer-specific configurations",
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id) or {}
            local buffnr = event.buf

            require("config.keymap").lsp().setup(buffnr)

            -- Enable LSP-based folding if the server supports it.
            if client:supports_method("textDocument/foldingRange") then
                local window = vim.api.nvim_get_current_win()
                assert(
                    vim.api.nvim_win_get_buf(window) == buffnr,
                    "tried to configure an unfocused window"
                )
                vim.wo[window][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
            end

            if client.name ~= "vtsls" and client.name ~= "sqls" and client:supports_method("textDocument/formatting") then
                enable_autofmt(buffnr, client)
            end
        end
    })

    catch_dynamic_formatting_registration()

    config_ui()

    --- Dummy function to avoid configuring an LSP.
    ---
    --- Usually done so that another plugin can handle it.
    local function no_config() end

    require("mason-lspconfig").setup({
        ensure_installed = packages.list.mason.lsp,
        automatic_installation = false,
        handlers = {
            -- Default
            vim.lsp.enable,
            -- Handled by other plugins
            jdtls = no_config,
            rust_analyzer = no_config
        }
    })
end

return module
