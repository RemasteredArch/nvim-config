# nvim-config

My personal Neovim config.

## Installation

### Requirements
* [Silicon](https://github.com/Aloxaf/silicon)
  * [Caskaydia Cove](https://github.com/eliheuer/caskaydia-cove)
  * [Noto Color Emoji](https://github.com/googlefonts/noto-emoji)
* Neovim 0.10.0 (built and used on [Neovim Unstable](https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable) on Ubuntu 20.04 & 22.04)

### Notes
* Assumes `$XDG_CONFIG_HOME` == `~/.config`. Adjust accordingly if this is otherwise.
* Assumes `~/.config/nvim` does not already exist. If it does, remove (preferably with a backup) this directory before installation.

### Steps
```
mkdir ~/.config
cd ~/.config
git clone https://github.com/RemasteredArch/nvim-config.git nvim/
```

## Notable plugins
* Plugin installation with [lazy.nvim](https://github.com/folke/lazy.nvim)
* LSP installation with [mason.nvim](https://github.com/williamboman/mason.nvim)
* Code screenshots with [nvim-silicon](https://github.com/michaelrommel/nvim-silicon)
* Java LSP with [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
* Rust LSP with [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
