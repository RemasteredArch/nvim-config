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

-- `typst.lua`: configurations for Typst editing
-- <https://typst.app/>

-- Tinymist formats it to this and I don't really feel like fixing that.
--
-- It might also just be built into Typst, I'm not sure.
require("config.options").spaces(2, true)

require("config.keymap").typst().setup()
