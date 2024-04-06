--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- cpp.lua: configuration for clangd

local function get_compiler()
  -- set your compiler (as it would be entered into a shell prompt)
  -- assumes that the compiler takes arguments like so: `<compiler> ExampleFile.cpp -o <output> <args>`
  local compilers = {
    preferred = "g++",
    other = { "clang++" }
  }

  if vim.fn.executable(compilers.preferred) == 1 then
    vim.notify("Using " .. compilers.preferred)
    return compilers.preferred
  end

  for _, compiler in ipairs(compilers.other) do
    if vim.fn.executable(compiler) == 1 then
      vim.notify("Using " .. compiler)
      return compiler
    end
  end

  vim.notify("No suitable C++ compiler found!")
end

local compiler = get_compiler();
local output = "./a.out"

-- compile and run file
vim.keymap.set("n", "<leader>r",
  string.format("<cmd>split | term %s %% -o %s; %s; rm %s<cr>", compiler, output, output, output))

-- compile and run file with args
vim.keymap.set("n", "<leader>cr", function()
  local user_input = vim.fn.input("Args: ")
  vim.api.nvim_command(
    string.format("split | term %s %% -o %s; %s %s; rm %s", compiler, output, output, user_input, output))
end)

-- compile and run file with args and compiler args
vim.keymap.set("n", "<leader>crr", function()
  local compiler_input = vim.fn.input("Compiler Args: ")
  local program_input = vim.fn.input("Program Args: ")
  vim.api.nvim_command(
    string.format("split | term %s %% -o %s %s; %s %s; rm %s", compiler, output, compiler_input, output, program_input,
      output))
end)
