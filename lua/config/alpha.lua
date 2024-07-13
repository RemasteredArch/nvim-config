--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2024 RemasteredArch

This file is part of nvim-config.

nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.
]]

-- alpha_config.lua: goolord/alpha.nvim configuration

local dashboard = require("alpha.themes.dashboard")

local fonts = {
  -- toilet --font <font name> nvim.
  future = {
    "┏┓╻╻ ╻╻┏┳┓ ",
    "┃┗┫┃┏┛┃┃┃┃ ",
    "╹ ╹┗┛ ╹╹ ╹╹"
  },
  mono9 = {
    "                ▀              ",
    "▄ ▄▄   ▄   ▄  ▄▄▄    ▄▄▄▄▄     ",
    "█▀  █  ▀▄ ▄▀    █    █ █ █     ",
    "█   █   █▄█     █    █ █ █     ",
    "█   █    █    ▄▄█▄▄  █ █ █    █"
  },
  mono12 = {
    "                       ██                    ",
    "                       ▀▀                    ",
    "██▄████▄  ██▄  ▄██   ████     ████▄██▄       ",
    "██▀   ██   ██  ██      ██     ██ ██ ██       ",
    "██    ██   ▀█▄▄█▀      ██     ██ ██ ██       ",
    "██    ██    ████    ▄▄▄██▄▄▄  ██ ██ ██     ██",
    "▀▀    ▀▀     ▀▀     ▀▀▀▀▀▀▀▀  ▀▀ ▀▀ ▀▀     ▀▀"
  },
  girly = { -- Modified from the mono9 font output
    "    ▄▄▄▄ ",
    "▀  ▀   ▀█",
    "     ▄▄▄▀",
    "▄      ▀█",
    "   ▀▄▄▄█▀"
  }
}

local font_keys = {}
for font_name in pairs(fonts) do
  table.insert(font_keys, font_name)
end

dashboard.section.header.val = fonts[font_keys[math.random(#font_keys)]]

dashboard.section.buttons.val = {
  dashboard.button("i", "  > New file", ":enew <BAR> startinsert <CR>"),
  dashboard.button("e", "  > Open Netrw", ":Explore <CR>"),
  dashboard.button("l", "󰒲  > Open Lazy", ":Lazy <CR>"),
  dashboard.button("m", "  > Open Mason", ":Mason <CR>"),
  dashboard.button("q", "󰈆  > Quit Neovim", ":qa <CR>")
}

dashboard.section.footer.val = {
  os.date(" %A, %Y-%m-%d   %I:%M %p")
}

dashboard.config.opts.setup = function()
  vim.api.nvim_buf_set_name(0, "<3") -- Set current buffer's name (default: [Scratch])
end

require("alpha").setup(dashboard.config)
