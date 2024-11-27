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

-- `nvim-rip-substitute.lua`: `chrisgrieser/nvim-rip-substitute` configuration

return {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
        {
            "<leader>rs",
            function()
                require("rip-substitute").sub()
            end,
            mode = { "n", "x" },
            desc = " substitute with ripgrep"
        }
    },
    config = function()
        require("rip-substitute").setup({
            popupWin = {
                title = " substitute with ripgrep"
            },
            prefill = {
                normal = false,
                visual = false
            },
            regexOptions = {
                -- `$1` -> `${1}` because `$1a != ${1}a` (breaks named capture groups)
                autoBraceSimpleCaptureGroups = true
            }
        })
    end
    -- Regex reference: <https://docs.rs/regex/1.10.5/regex/#syntax>
}
