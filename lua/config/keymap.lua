--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- keymap.lua: various key mappings

--- @alias VimModeShort # See |modes()|
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
--- @class (exact) KeyMappingsAndSetup
--- @field mappings KeymapTuple[]
--- @field setup fun()

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

--- Key mappings for nvim-cmp.
---
--- @return table<string, cmp.Mapping>
function module.cmp()
  -- local cmp_action = require("lsp-zero").cmp_action() -- A few helper actions
  local cmp = require("cmp")

  -- Adds keybinds onto the existing preset
  return cmp.mapping.preset.insert({
    -- Selects and confirms the current item
    -- Use select = false to require manual selection
    ["<Tab>"] = cmp.mapping.confirm({ select = true })
  })
end

--- Key mappings for Java.
---
--- @param buffnr integer
--- @param root_files path[]
--- @return KeyMappingsAndSetup
function module.java(buffnr, root_files)
  --- @type KeymapTuple[]
  local mappings = {
    -- In normal mode, press alt+o[rganize] to organize imports
    { "n", "<A-o>",      function() require("jdtls").organize_imports() end },

    -- In normal and visual mode mode, press c,r[efactor],v[ariable] to extract a variable
    { "n", "crv",        function() require("jdtls").extract_variable() end },
    { "x", "crv",        function() require("jdtls").extract_variable({ visual = true }) end },

    -- In normal and visual mode, press c,r[efactor],c[onstant] to extract a constant
    { "n", "crc",        function() require("jdtls").extract_constant() end },
    { "x", "crc",        function() require("jdtls").extract_constant({ visual = true }) end },

    -- In visual mode, press c,r[efactor],m[ethod] to extract a method
    { "x", "crm",        function() require("jdtls").extract_method({ visual = true }) end },

    -- In normal mode, press space,r[un] to run the single-file code in the current buffer (or c[onfig]r[un] to run with input)
    { "n", "<leader>r",  "<cmd>split | term java %<cr>" },
    { "n", "<leader>cr", function() vim.api.nvim_command("split | term java % " .. vim.fn.input("Args: ")) end },

    -- Look into binding JdtCompile, JdtJshell, and maybe JdtJol
    -- https://github.com/mfussenegger/nvim-jdtls#usage

    --[[
      -- same but space,f[ull],r[un] (or space,f[ull],c[onfig],r[un]) for multiple files
      -- see: https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fcore%2Fresources%2Fpackage-summary.html
      -- see: https://github.com/eclipse-jdtls/eclipse.jdt.ls/blob/27a1a1e1f6e1b598b5d9cb5ef00b3783b7ee458a/org.eclipse.jdt.ls.core/src/org/eclipse/jdt/ls/core/internal/handlers/BuildWorkspaceHandler.java#L47
      -- see: incremental builds https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fcore%2Fresources%2FIncrementalProjectBuilder.html&anchor=FULL_BUILD
      { "n", "<leader>fr", function()
        vim.api.nvim_command("JdtCompile")
        local bin_dir = require("jdtls").setup.find_root(root_files) .. "/bin"
        vim.print(bin_dir)
        --vim.api.nvim_command("split | term java % <cr>")
      end }
    ]]
  }

  local function setup()
    module.set_all(mappings, buffnr)
  end

  return { mapping = mappings, setup = setup }
end

--- Key mappings for Rust.
---
--- @return KeyMappingsAndSetup
function module.rust()
  --- @type KeymapTuple[]
  local mappings = {
    -- Expand diagnostics
    { "n", "<leader>gl", function() vim.diagnostic.open_float() end },

    -- Run project
    { "n", "<leader>r",  "<cmd>split | term cargo run<cr>" }, -- Maybe cd into the file's directory first
    { "n", "<leader>cr", function() vim.api.nvim_command("split | term cargo run -- " .. vim.fn.input("Args: ")) end },
  }

  local function setup()
    module.set_all(mappings)
  end

  return { mapping = mappings, setup = setup }
end

return module
