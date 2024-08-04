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

-- silicon.lua: configuration for nvim-silicon, intended to be used directly in package_list.lua

return {
  "michaelrommel/nvim-silicon",
  lazy = true,
  cmd = "Silicon",
  config = function()
    local output_path = vim.fn.stdpath("data") .. "/silicon"

    if vim.fn.isdirectory(output_path) == 0 then
      vim.fn.mkdir(output_path)
    end

    require("nvim-silicon").setup({
      font = "CaskaydiaCove Nerd Font=34;Noto Color Emoji=34",
      tab_width = 2,
      theme = "OneHalfDark", -- `silicon --list-themes` (also nice: "Visual Studio Dark+")
      line_offset = function(args)
        return args.line1
      end,
      output = function()
        return output_path .. "/" .. vim.fn.expand("%:t") .. ".silicon.png"
      end,
      window_title = function()
        return vim.fn.expand("%:t")
      end,
      to_clipboard = true,
      wslclipboard = "auto",
      wslclipboardcopy = "keep",
    })
  end
}
