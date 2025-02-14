--[[
SPDX-License-Identifier: AGPL-3.0-or-later

Copyright © 2025 RemasteredArch

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

-- `commands.lua`: miscellaneous user commands

local module = {}

local function normalize_whitespace()
    --- The 25 characters defined as whitespace.
    ---
    --- - <https://vi.stackexchange.com/a/33312>
    --- - <https://en.wikipedia.org/wiki/Whitespace_character#Unicode>
    local whitespace_codepoints = {
        "0009", -- Character tabulation
        "000A", -- Line feed (LF)
        "000B", -- Line tabulation
        "000C", -- Form feed (FF)
        "000D", -- Carriage return (CR)
        -- "0020", -- Space (disabled because it's redundant)
        "0085", -- Next line (NEL)
        "00A0", -- No-break space (NBSP)
        "1680", -- Ogham space mark
        "2000", -- En quad
        "2001", -- Em quad
        "2002", -- En space
        "2003", -- Em space
        "2004", -- Three-per-em space
        "2005", -- Four-per-em space
        "2006", -- Six-per-em space
        "2007", -- Figure space
        "2008", -- Punctuation space
        "2009", -- Thin space
        "200A", -- Hair space
        "2028", -- Line separator
        "2029", -- Paragraph separator
        "202F", -- Narrow no-break space
        "205F", -- Medium mathematical space
        "3000"  -- Ideographic space
    };
    whitespace_codepoints = vim.tbl_map(
        function(codepoint)
            -- E.g., `"000A"` -> `"\%u000A"`.
            return "\\%u" .. codepoint
        end,
        whitespace_codepoints
    )

    --- Regex find and replace: `"s/\(%u0009\|%u000A\|...\)/ /g"`.
    local replace_whitespace_with_space =
        "s/\\(" .. table.concat(whitespace_codepoints, "\\|") .. "\\)/ /g"

    vim.api.nvim_create_user_command(
        "NormalizeWhitespace",
        replace_whitespace_with_space,
        {
            force = true,
            range = true
        }
    )
end

function module.setup()
    normalize_whitespace()
end

return module
