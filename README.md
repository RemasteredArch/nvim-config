# nvim-config

My personal Neovim config.

This is posted here more for convenience than anything else. This config is *not* stable, is *not* guaranteed to function as expected (or at all), is *not* expertly made, and is probably *not* appropriate for your use case.

## Installation

### Requirements
* [Silicon](https://github.com/Aloxaf/silicon)
  * [Caskaydia Cove](https://github.com/eliheuer/caskaydia-cove)
  * [Noto Color Emoji](https://github.com/googlefonts/noto-emoji)
* g++
* Neovim 0.10.0 (built and used on [Neovim Unstable](https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable) on Ubuntu 20.04 & 22.04)

### Steps
* Assumes `$XDG_CONFIG_HOME` == `~/.config`. Adjust accordingly if this is otherwise.
* Assumes `~/.config/nvim` does not already exist. If it does, remove it (preferably with a backup) before installation.

```bash
mkdir ~/.config
cd ~/.config
git clone https://github.com/RemasteredArch/nvim-config.git nvim/
sudo apt install g++ # substitute your distro's equivalent here
```

## Notable plugins
* Plugin installation with [lazy.nvim](https://github.com/folke/lazy.nvim)
* LSP installation with [mason.nvim](https://github.com/williamboman/mason.nvim)
* Code screenshots with [nvim-silicon](https://github.com/michaelrommel/nvim-silicon)
* Java LSP with [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
* Rust LSP with [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
* UI with [noice.nvim](https://github.com/folke/noice.nvim)
  * I'm likely to majorly change or entirely remove this, as I am not happy with it yet
* C++ LSP with [clangd](https://clangd.llvm.org/)

## License

nvim-config is licensed under the GNU Affero General Public License version 3, or (at your option) any later version. You should have received a copy of the GNU Affero General Public License along with nvim-config, found in [LICENSE](./LICENSE). If not, see <[https://www.gnu.org/licenses/](https://www.gnu.org/licenses/)>.

nvim-config contains code from other software. See [COPYING.md](./COPYING.md) for more details.
