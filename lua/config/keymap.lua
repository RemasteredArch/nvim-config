--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- keymap.lua: various key mappings

local module = {}

-- Sets a key mapping
function module.set(mode, key, effect, opts)
  vim.keymap.set(mode, key, effect, opts)
end

function module.set_all(binds, buffnr)
  local function expand_keymap(keymap)
    local mode = keymap[1]
    local key = keymap[2]
    local effect = keymap[3]
    local opts = keymap[4] or {}

    if buffnr then
      opts.buffer = buffnr
    end

    module.set(mode, key, effect, opts)
  end

  vim.tbl_map(expand_keymap, binds)
end

-- Key mappings for nvim-cmp
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

function module.java(buffnr, root_files)
  local mappings = {
    -- In normal mode, press alt+o[rganize] to organize imports
    { "n", "<A-o>",      function() require("jdtls").organize_imports() end },

    -- In normal and visual mode mode, press c,r[efactor],v[ariable] to extract a variable
    { "n", "crv",        function() require("jdtls").extract_variable() end },
    { "x", "crv",        function() require("jdtls").extract_variable(true) end },

    -- In normal and visual mode, press c,r[efactor],c[onstant] to extract a constant
    { "n", "crc",        function() require("jdtls").extract_constant() end },
    { "x", "crc",        function() require("jdtls").extract_constant(true) end },

    -- In visual mode, press c,r[efactor],m[ethod] to extract a method
    { "x", "crm",        function() require("jdtls").extract_method(true) end },

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

return module
