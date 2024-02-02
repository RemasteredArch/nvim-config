--[ OPTIONS ]--

-- global options
local g = vim.g -- global vars and options
g.mapleader = " " -- sets starting key for custom keybinds

local opt = vim.opt -- ?? how different from vim.g?

-- current line behavior
opt.cursorline = true -- highlights the current line
opt.number = true -- sets line numbers
opt.relativenumber = true -- sets line numbering as relative to current line

-- colors
opt.termguicolors = true -- enabled coloring
opt.background = "dark"
local colorscheme = "slate"
local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not ok then
  print("colorscheme " .. colorscheme .. " was not found!")
  return
end

--[ PLUGINS ]--

-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- treesitter
require("lazy").setup({{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function ()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      -- list of parsers to always have instlaled, the first 5 are required
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "html", "css", "rust", "java" },
      
      -- install the above ensured parsers synchronously
      sync_install = false,

      highlight = {
        enable = true,
        --[[ -- disables syntax highlighting for overly large files
        disable = function(lang, buf)
          local maxFilesize = 100 * 1024 -- 100 KiB
	  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats > maxFilesize then
	    return true
          end
        end,
        ]]--
        additional_vim_regex_highlighting = false
      }
    })
  end
}})

