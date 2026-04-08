--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2026 RemasteredArch

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

-- `nix.lua`: utilities for handling configuration under Nix/NixOS.

local M = {}

--- Detects whether the current operating system is NixOS.
---
--- This is useful, for example, for determining whether to install packages that require an FHS
--- system.
---
--- @return boolean
function M.is_nixos()
    return vim.fn.isdirectory("/etc/nixos") == 1
end

--- Detects whether Nix is installed by checking for `nix`.
---
--- @return boolean
function M.has_nix()
    return vim.fn.executable("nix") == 1
end

return M
