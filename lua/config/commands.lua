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

--- Register a command, `NormalizeWhitespace`, to replace whitespace with spaces (`U+0020`), fold
--- successive spaces into one, and strip trailing spaces.
---
--- @param buffnr integer The buffer ID to register the command in.
local function normalize_whitespace(buffnr)
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

    --- Reduces all instances of two or more successive spaces to one single space.
    local flatten_repeat_spaces = "s/  \\+/ /g"

    --- Strips all spaces at the end of lines.
    ---
    --- Assumes it will be run *after* `flatten_repeat_spaces`.
    local strip_trailing_spaces = "s/ $//g"

    vim.api.nvim_buf_create_user_command(
        buffnr,
        "NormalizeWhitespace",
        function(opts)
            local range = ""

            -- `opts` is guaranteed to have the following, no need for a null check.
            --
            -- See `:help lua-guide-commands-create` or `:help nvim_create_user_command()`.
            if opts.range == 2 then
                range = opts.line1 .. "," .. opts.line2
            end

            for _, substitution in ipairs({
                replace_whitespace_with_space,
                flatten_repeat_spaces,
                strip_trailing_spaces
            }) do
                -- `e` suppresses E486 "Pattern not found" from unmatched substitutions.
                --
                -- See `:help s_e`.
                vim.cmd(range .. substitution .. "e")
            end
        end,
        {
            desc = "Replace whitespace with spaces (`U+0020`), "
                .. "fold successive spaces into one, and "
                .. "strip trailing spaces",
            force = true,
            range = true
        }
    )
end

--- Register a command to write without LSP formatting or other autocmds.
---
--- @param buffnr integer The buffer ID to register the command in.
local function write(buffnr)
    vim.api.nvim_buf_create_user_command(
        buffnr,
        "Write",
        "noautocmd write",
        {
            desc = "Write without LSP formatting or other autocmds",
            force = true
        }
    )
end

--- Register miscellaneous user commands.
---
--- @param buffnr integer? The buffer ID to register the commands in. Defaults to current buffer.
function module.setup(buffnr)
    buffnr = buffnr or vim.api.nvim_get_current_buf()

    normalize_whitespace(buffnr)
    write(buffnr)
end

return module
