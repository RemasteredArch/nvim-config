--[ OPTIONS ]--
local g = vim.g -- global vars and options
g.mapleader = " " -- sets starting key for custom keybinds

local opt = vim.opt -- ?? how different from vim.g?

opt.termguicolors = true -- enabled coloring
opt.cursorline = true -- highlights the current line
opt.number = true -- sets line numbers
opt.background = "dark"
opt.relativenumber = true -- sets line numbering as relative to current line

--[ PLUGINS ]--
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
--require("lazy").setup(plugins, opts)

