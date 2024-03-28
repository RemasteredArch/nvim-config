--[ OPTIONS ]--

-- global options
local g = vim.g     -- global vars and options
g.mapleader = " "   -- sets starting key for custom keybinds

local opt = vim.opt -- ?? how different from vim.g?

-- current line behavior
opt.cursorline = true     -- highlights the current line
opt.number = true         -- sets line numbers
opt.relativenumber = true -- sets line numbering as relative to current line

-- spaces instead of tabs
local function spaces()
  opt.tabstop = 8 -- number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = true
  opt.shiftwidth = 2
end

-- tabs instead of spaces
local function tabs()
  opt.tabstop = 2 -- number of spaces that tab chars render as
  opt.softtabstop = 0
  opt.expandtab = false
  opt.shiftwidth = 2
end

spaces()

-- wrap lines on whitespace, etc instead of at the last character that fits
opt.linebreak = true

-- colors
opt.termguicolors = true             -- enables coloring
opt.background = "dark"
function SetColorscheme(colorscheme) -- allows setting colorscheme to fail loudly... vim.cmd.colorscheme = "whatever" will fail silently
  local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
  if not ok then
    print("colorscheme " .. colorscheme .. " was not found!")
    return
  end
end

SetColorscheme("slate") -- set colorscheme using a built-in as a fallback

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

require("lazy").setup({
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        -- list of parsers to always have installed, the first 5 are required
        ensure_installed = {
          "c", "lua", "vim", "vimdoc", "query", "javascript", "html", "css", "rust", "java", "bash", "markdown", "toml",
          "json", "jsonc", "xml"
        },

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
					]] --
          additional_vim_regex_highlighting = false
        }
      })
    end
  },

  -- color scheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
  },

  -- code screenshots
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    config = function()
      local output_path = vim.fn.stdpath("data") .. "/silicon"
      if vim.fn.isdirectory(output_path) == 0 then
        vim.fn.mkdir(output_path)
      end

      require("silicon").setup({
        font = "CaskaydiaCove Nerd Font=34;Noto Color Emoji=34",
        tab_width = 2,
        theme = "OneHalfDark", -- silicon --list-themes
        -- also nice: "Visual Studio Dark+"
        line_offset = function(args)
          return args.line1
        end,
        output = function()
          return string.format("%s/silicon/%s.silicon.png", vim.fn.stdpath("data"), vim.fn.expand("%:t"))
        end,
        window_title = function()
          return vim.fn.expand("%:t")
        end
      })
    end
  },
  {
    "ziontee113/icon-picker.nvim",
    --lazy = true,
    config = function()
      require("icon-picker").setup({ disable_legacy_commands = true })
    end
  },

  -- UI
  {
    "stevearc/dressing.nvim",
    -- opts = {} -- e.g. insert_only = true by default
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },


  -- LSP/DAP
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "VonHeikemen/lsp-zero.nvim",        branch = "v3.x" },
  { "mfussenegger/nvim-jdtls" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/nvim-cmp" },
  { "L3MON4D3/LuaSnip" },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "mrcjkb/rustaceanvim" },

})

-- colorscheme
SetColorscheme("catppuccin-mocha")

-- UI
require("noice").setup({
  presets = {
    bottom_search = true,
    command_palette = true,
    lsp_doc_border = true
  }
})

--[ LSPs ]--
local lsp_zero = require("lsp-zero")

-- lspzero https://lsp-zero.netlify.app/v3.x/getting-started.html

lsp_zero.on_attach(function(client, buffnr)
  -- :help lsp-zero-keybindings
  lsp_zero.default_keymaps({ buffer = buffnr })
  lsp_zero.buffer_autoformat()
end)

-- for more on mason + lspzero:
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
-- or https://lsp-zero.netlify.app/v3.x/guide/integrate-with-mason-nvim.html
require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "jdtls", -- java, see also see mfussenegger/nvim-jdtls
    "bashls",
    "lua_ls",
    "marksman", -- markdown
    "gradle_ls",
    "taplo",    -- toml
    "biome",    -- ts, js, jsx, json, jsonc, etc.
    "lemminx",  -- xml
    "rust_analyzer"
  },            -- from: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
  automatic_installation = false,
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
    lua_ls = function()
      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                "vim"
              }
            }
          }
        }
      })
    end,
    rust_analyzer = lsp_zero.noop,
    taplo = function()
      local taplo_cmds = vim.api.nvim_create_augroup("taplo_cmds", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = taplo_cmds,
        pattern = "*.toml",
        desc = "Format on write",
        callback = function()
          vim.lsp.buf.format()
        end
      })
    end
  }
})

vim.g.rustaceanvim = {
  -- tools = {}, -- plugins
  server = { -- lsp
    capabilities = lsp_zero.get_capabilities()
  }
  -- dap = {}
}

--[[
-- Automatically set unusual filetypes
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = {*.extension},
	command = "set filetype=lang"
}
]]
--

-- spiders🕷️🕸️
