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

-- `nvim-treesitter.lua`: `nvim-treesitter/nvim-treesitter` configuration.

local M = {}

--- Installs and sets up a parser for Caddyfiles, the configuration DSL used by the Caddy web
--- server.
---
--- <https://caddyserver.com/docs/caddyfile-tutorial>
local function setup_caddy()
    local join = vim.fs.joinpath
    local exists = vim.uv.fs_stat

    -- This shouldn't be here, but I'll move it when I get around to setting up the formatter.
    vim.filetype.add({
        filename = {
            ["Caddyfile"] = "caddyfile"
        }
    })

    --- @type InstallInfo
    local install_info = {
        url = "https://github.com/matthewpi/tree-sitter-caddyfile",
        branch = "2c74f94ca43748e01f336b774324b98f93aa0de4",
        files = { "src/parser.c" }
    }

    --- @type table<string, ParserInfo>
    local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
    --- @diagnostic disable-next-line: missing-fields
    parser_configs.caddyfile = { install_info = install_info }

    if not vim.tbl_contains(require("nvim-treesitter.info").installed_parsers(), "caddyfile") then
        vim.cmd.TSInstall("caddyfile")
    end

    -- nvim-treesitter searches for queries by getting `$RTP/queries/*/*.scm`, so it's necessary to
    -- nest the `queries` directory within another directory that gets added to the runtime paths.
    --
    -- ```
    -- + Data directory, e.g., `~/.local/share/nvim/`.
    -- |
    -- + `lazy/`
    -- |
    -- + etc.
    -- |
    -- +-+ `treesitter/`
    -- | |
    -- | +-+ `queries/`
    -- | | |
    -- | | +-+ `someotherlang/`
    -- | | |
    -- | | +-+ `caddyfile/`
    -- | | | |
    -- | | | +- `commit.lock`
    -- | | | |
    -- | | | +- `highlights.scm`
    -- | | | |
    -- | | | +- etc.
    -- | | | |
    -- ```
    vim.opt.rtp:prepend(join(vim.fn.stdpath("data"), "tree-sitter"))

    local query_directory = join(vim.fn.stdpath("data"), "tree-sitter", "queries")
    local caddy_query_directory = join(query_directory, "caddyfile")

    -- If queries already exist and are up to date, return.
    local lock_file = join(caddy_query_directory, "commit.lock")
    if exists(lock_file) and vim.fn.readfile(lock_file)[1] == install_info.branch then
        return
    end

    -- If missing, create directory tree.
    if not exists(query_directory) then
        vim.fn.mkdir(query_directory, "p")
    end

    -- Selects the correct shell commands for various operations, in a format consumable by
    -- `iter_cmd`.
    local shell = require("nvim-treesitter.shell_command_selectors")

    local name = "tree-sitter-caddyfile"
    local prefer_git = false
    local cache_dir, err = require("nvim-treesitter.utils").get_cache_dir()
    assert(cache_dir, err or "expected extant, readable, and writeable cache directory")

    -- Downloads the contents of the repository to `join(cache_dir, name)`.
    local download_commands = shell.select_download_commands(
        install_info,
        name,
        cache_dir,
        install_info.branch,
        prefer_git
    )
    -- Moves the queries in the repository into the Caddy query directory.
    table.insert(
        download_commands,
        shell.select_mv_cmd(
            join(cache_dir, name, "queries"),
            caddy_query_directory,
            cache_dir
        )
    )
    -- Removes the rest of the repository.
    table.insert(download_commands, shell.select_install_rm_cmd(cache_dir, name))
    -- Creates the lock file with the current commit.
    table.insert(download_commands, {
        cmd = function()
            vim.fn.writefile({ install_info.branch }, lock_file)
        end
    })

    -- Actually execute the above commands. Does so in an asynchronous manner.
    --
    -- This will emit messages tailored towards parser installs, but it works so well that I am not
    -- going to reimplement it just because of some weird messages.
    require("nvim-treesitter.install").iter_cmd(
        download_commands,
        1,
        "caddyfile",
        "Tree-sitter queries for Caddyfiles have been installed"
    )
end

function M.with_ensure_installed(list)
    return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")

            --- @diagnostic disable-next-line: missing-fields
            configs.setup({
                --- List of parsers to always have installed.
                ---
                --- List with `:TSInstallInfo`.
                ensure_installed = list,
                --- Install the above ensured parsers (a)synchronously.
                sync_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                }
            })

            setup_caddy()
        end
    }
end

return M
