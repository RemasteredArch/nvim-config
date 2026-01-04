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

-- `keymap.lua`: various key mappings.

--- @module "lazy"

--- @alias VimModeShort # See |modes()|.
--- | "n" Normal
--- | "no" Operator-pending
--- | "nov" Operator-pending (forced charwise |o_v|)
--- | "noV" Operator-pending (forced linewise |o_V|)
--- | "noCTRL-V" Operator-pending (forced blockwise |o_CTRL-V|) CTRL-V is one character
--- | "niI" Normal using |i_CTRL-O| in |Insert-mode|
--- | "niR" Normal using |i_CTRL-O| in |Replace-mode|
--- | "niV" Normal using |i_CTRL-O| in |Virtual-Replace-mode|
--- | "nt" Normal in |terminal-emulator| (insert goes to Terminal mode)
--- | "ntT" Normal using |t_CTRL-\_CTRL-O| in |Terminal-mode|
--- | "x" Visual
--- | "v" Visual by character
--- | "vs" Visual by character using |v_CTRL-O| in Select mode
--- | "V" Visual by line
--- | "Vs" Visual by line using |v_CTRL-O| in Select mode
--- | "CTRL-V" Visual blockwise
--- | "CTRL-Vs" Visual blockwise using |v_CTRL-O| in Select mode
--- | "s" Select by character
--- | "S" Select by line
--- | "CTRL-S" Select blockwise
--- | "i" Insert
--- | "ic" Insert mode completion |compl-generic|
--- | "ix" Insert mode |i_CTRL-X| completion
--- | "R" Replace |R|
--- | "Rc" Replace mode completion |compl-generic|
--- | "Rx" Replace mode |i_CTRL-X| completion
--- | "Rv" Virtual Replace |gR|
--- | "Rvc" Virtual Replace mode completion |compl-generic|
--- | "Rvx" Virtual Replace mode |i_CTRL-X| completion
--- | "c" Command-line editing
--- | "cr" Command-line editing overstrike mode |c_<Insert>|
--- | "cv" Vim Ex mode |gQ|
--- | "cvr" Vim Ex mode while in overstrike mode |c_<Insert>|
--- | "r" Hit-enter prompt
--- | "rm" The -- more -- prompt
--- | "r?" A |:confirm| query of some sort
--- | "!" Shell or external command is executing
--- | "t" Terminal mode: keys go to the job
---
--- @class (exact) Keymap A Neovim keymap, similar to the parameters of `vim.keymap.set()`
--- @field mode VimModeShort | VimModeShort[] Vim mode(s) the keybind should be active in
--- @field key string The actual keybind
--- @field effect string | function The effect of the keymap, either a Neovim Ex command or a function
--- @field opts vim.keymap.set.Opts? The options of the keymap
---
--- @alias KeymapTuple [VimModeShort | VimModeShort[], string , string | function, vim.keymap.set.Opts?] A Neovim keymap represented as a tuple
---
--- @class (exact) KeyMappingsAndSetup Some keymappings and a function to register them
--- @field mappings KeymapTuple[] The associated keymappings
--- @field setup fun(buffnr: integer?) A function to register the associated keymappings

local module = {}

--- Sets a key mapping.
---
--- Just a wrapper around `vim.keymap.set()`.
---
--- @param keymap Keymap
function module.set(keymap)
    vim.keymap.set(keymap.mode, keymap.key, keymap.effect, keymap.opts)
end

--- Set a list of keymaps in a given buffer.
---
--- @param binds KeymapTuple[]
--- @param buffnr integer?
function module.set_all(binds, buffnr)
    local function expand_keymap(keymap)
        local map = {
            mode = keymap[1],
            key = keymap[2],
            effect = keymap[3],
            opts = keymap[4] or {}
        }

        if buffnr then
            map.opts.buffer = buffnr
        end

        module.set(map)
    end

    vim.tbl_map(expand_keymap, binds)
end

--- Construct a `KeyMappingsAndSetup`.
---
--- @see KeyMappingsAndSetup
---
--- @param mappings KeymapTuple[]
--- @return KeyMappingsAndSetup
local function mappings_and_setup(mappings)
    local function setup(buffnr)
        module.set_all(mappings, buffnr)
    end

    return { mapping = mappings, setup = setup }
end

--- Key mappings related to diagnostics.
---
--- These used to be a part of the LSP keybindings, but this would neglect filetypes with only
--- linters. It's now a generic item.
---
--- @return KeyMappingsAndSetup
function module.diagnostics()
    return mappings_and_setup({
        -- Expand diagnostic in a floating window
        { "n", "<leader>gl", vim.diagnostic.open_float }
    })
end

--- Key mappings for nvim-cmp.
---
--- @return table<string, cmp.Mapping>
function module.cmp()
    local cmp = require("cmp")

    -- Adds keybinds onto the existing preset.
    return cmp.mapping.preset.insert({
        -- Selects and confirms the current item.
        --
        -- Use `select = false` to require manual selection.
        ["<Tab>"] = cmp.mapping.confirm({ select = true })
    })
end

--- Key mappings for LSPs.
---
--- Modified from LSP Zero. Copyright © 2024 Heiker Curiel, MIT license.
---
--- - <https://lsp-zero.netlify.app/docs/language-server-configuration.html#default-keymaps>
--- - <https://github.com/VonHeikemen/lsp-zero.nvim/blob/60a66bf/LICENSE>
---
--- @return KeyMappingsAndSetup
function module.lsp()
    return mappings_and_setup({
        -- Open documentation in a floating window
        { "n", "K", vim.lsp.buf.hover },
        -- Go to definition
        { "n", "gd", vim.lsp.buf.definition },
        -- Go to declaration
        { "n", "gD", vim.lsp.buf.declaration },
        -- Go to implementation
        { "n", "gi", vim.lsp.buf.implementation },
        -- Go to type definition
        { "n", "go", vim.lsp.buf.type_definition },
        -- Go to reference
        { "n", "gr", vim.lsp.buf.references },
        -- Show function signature in a floating window
        { "n", "gs", vim.lsp.buf.signature_help },
        -- Rename symbol
        { "n", "<F2>", vim.lsp.buf.rename },
        -- Execute code action
        { "n", "<F4>", vim.lsp.buf.code_action }
    })
end

--- Key mappings for Java.
---
--- @param root_files path[]
--- @return KeyMappingsAndSetup
function module.java(root_files)
    local jdtls = require("jdtls")

    return mappings_and_setup({
        -- In normal mode, press alt+o[rganize] to organize imports
        { "n", "<A-o>", jdtls.organize_imports },

        -- In normal and visual mode mode, press c,r[efactor],v[ariable] to extract a variable
        { "n", "crv", jdtls.extract_variable },
        { "x", "crv", function() jdtls.extract_variable({ visual = true }) end },

        -- In normal and visual mode, press c,r[efactor],c[onstant] to extract a constant
        { "n", "crc", jdtls.extract_constant },
        { "x", "crc", function() jdtls.extract_constant({ visual = true }) end },

        -- In visual mode, press c,r[efactor],m[ethod] to extract a method
        { "x", "crm", function() jdtls.extract_method({ visual = true }) end },

        -- In normal mode, press space,r[un] to run the single-file code in the current buffer (or c[onfig]r[un] to run with input)
        { "n", "<leader>r", "<cmd>split | term java %<cr>" },
        {
            "n",
            "<leader>cr",
            function() vim.api.nvim_command("split | term java % " .. vim.fn.input("Args: ")) end
        }
    })
end

--- Key mappings for Rust.
---
--- @return KeyMappingsAndSetup
function module.rust()
    return mappings_and_setup({
        -- Run project.
        --
        -- Maybe `cd` into the file's directory first?
        { "n", "<leader>r", "<cmd>split | term cargo run<cr>" },
        {
            "n",
            "<leader>cr",
            function() vim.api.nvim_command("split | term cargo run -- " .. vim.fn.input("Args: ")) end
        },
        -- Expand macros in a split.
        { "n", "<F3>", "<cmd>RustLsp expandMacro<cr>" },
        -- Open error information from the Rust error codes index in a pop-up.
        { "n", "<leader>ee", "<cmd>RustLsp explainError<cr>" },
        -- Render diagnostics as they come from Cargo.
        { "n", "<leader>ed", "<cmd>RustLsp renderDiagnostic<cr>" }
    })
end

--- Key mappings for Telescope.
---
--- @return KeyMappingsAndSetup
function module.telescope()
    local builtin = require("telescope.builtin")

    return mappings_and_setup({
        -- Open file picker for current directory.
        { "n", "ff", builtin.find_files },

        -- Open file picker for Git files.
        { "n", "fg", builtin.git_files },

        -- Open live regex search.
        { "n", "flg", builtin.live_grep },

        -- Open live document symbol search from LSP.
        { "n", "fls", builtin.lsp_document_symbols },

        -- Open help tag search.
        { "n", "flh", builtin.help_tags }
    })
end

--- Key mappings for `iamcco/markdown-preview.nvim`.
---
--- @return KeyMappingsAndSetup
function module.markdown_preview()
    return mappings_and_setup({
        { "n", "<leader>p", "<cmd>MarkdownPreviewToggle<cr>" }
    })
end

--- Key mappings for Typst editing.
---
--- <https://typst.app/>
---
--- @return KeyMappingsAndSetup
function module.typst()
    return mappings_and_setup({
        -- Open a preview of the current document in the browser.
        --
        -- <https://github.com/chomosuke/typst-preview.nvim>
        { "n", "<leader>p", "<cmd>TypstPreview<cr>" }
    })
end

--- Key mappings for `mfussenegger/nvim-dap` and `rcarriga/nvim-dap-ui`.
---
--- @return KeyMappingsAndSetup
function module.dap()
    local dap = require("dap")

    return mappings_and_setup({
        { "n", "<leader>dt", require("dapui").toggle },
        { "n", "<leader>do", dap.step_over },
        { "n", "<leader>di", dap.step_into },
        { "n", "<leader>dO", dap.step_out },
        { "n", "<leader>db", dap.step_back }
    })
end

--- Key mappings for shell scripts.
---
--- @return KeyMappingsAndSetup
function module.sh()
    return mappings_and_setup({
        { "n", "<leader>r", "<cmd>split | term ./" .. vim.fn.expand("%") .. "<cr>" },
        {
            "n",
            "<leader>cr",
            function()
                local user_input = vim.fn.input("Args: ")
                vim.api.nvim_command("split | term ./" .. vim.fn.expand("%") .. " " .. user_input)
            end
        }
    })
end

--- Key mappings for C++.
---
--- @return KeyMappingsAndSetup
function module.cpp()
    local cpp = require("util.cpp")
    local compiler = cpp.get_compiler()

    return mappings_and_setup({
        -- Compile and run file.
        {
            "n",
            "<leader>r",
            string.format(
                "<cmd>split | term %s %% -o %s; %s; rm %s<cr>",
                compiler,
                cpp.output,
                cpp.output,
                cpp.output
            )
        },

        -- Compile and run file with args.
        {
            "n",
            "<leader>cr",
            function()
                local user_input = vim.fn.input("Args: ")
                vim.api.nvim_command(string.format(
                    "split | term %s %% -o %s; %s %s; rm %s",
                    compiler,
                    cpp.output,
                    cpp.output,
                    user_input,
                    cpp.output
                ))
            end
        },

        -- Compile and run file with args and compiler args.
        {
            "n",
            "<leader>crr",
            function()
                local compiler_input = vim.fn.input("Compiler Args: ")
                local program_input = vim.fn.input("Program Args: ")
                vim.api.nvim_command(string.format(
                    "split | term %s %% -o %s %s; %s %s; rm %s",
                    compiler,
                    cpp.output,
                    compiler_input,
                    cpp.output,
                    program_input,
                    cpp.output
                ))
            end
        },

        -- Build CMake config (only if necessary) and compile project.
        { "n", "<leader>ccb", cpp.cmake_build },

        -- Run compiled project.
        --
        -- This doesn't actually need to be like this -- Ninja will detect no changes!
        { "n", "<leader>ccr", cpp.cmake_run }

    })
end

--- @return LazyKeysSpec[]
function module.nvim_rip_substitute()
    return {
        {
            "<leader>rs",
            function()
                require("rip-substitute").sub()
            end,
            mode = { "n", "x" },
            desc = " substitute with ripgrep"
        }
    }
end

--- Keybindings for [sqls](https://github.com/sqls-server/sqls), a SQL language server.
---
--- Depends on [sqls.nvim](https://github.com/nanotee/sqls.nvim/).
---
--- @return KeyMappingsAndSetup
function module.sqls()
    return mappings_and_setup({
        { "n", "<leader>r", "<cmd>SqlsExecuteQuery<cr>" }
    })
end

return module
