# nvim-config

My personal Neovim config.

This is posted here more for convenience than anything else. This config is *not* stable, is *not* guaranteed to function as expected (or at all), is *not* expertly made, and is probably *not* appropriate for your use case.

## Notable plugins

* Plugin installation with [lazy.nvim](https://github.com/folke/lazy.nvim)
* LSP installation with [mason.nvim](https://github.com/williamboman/mason.nvim)
* LSP configuration with [LSP Zero](https://github.com/VonHeikemen/lsp-zero.nvim)
* Code screenshots with [nvim-silicon](https://github.com/michaelrommel/nvim-silicon)
* Java LSP configuration with [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
* Rust LSP configuration with [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)

## Installation

### Requirements
* [Silicon](https://github.com/Aloxaf/silicon)
  * [Caskaydia Cove](https://github.com/eliheuer/caskaydia-cove)
  * [Noto Color Emoji](https://github.com/googlefonts/noto-emoji)
* [CMake](https://cmake.org/)
  * [`g++`](https://gcc.gnu.org/) or [`clang++`](https://clang.llvm.org/) (configurable, see [`ftplugin/cpp.lua`](./ftplugin/cpp.lua))
  * [Ninja](https://ninja-build.org/) (configurable, see [`ftplugin/cpp.lua`](./ftplugin/cpp.lua))
* [Node.js](https://nodejs.org/en)
  * This config is built and used with node.js v20.12.2 (installed through [`nvm install --lts`](https://github.com/nvm-sh/nvm)), but older or newer versions would likely work fine
* [Rust](https://www.rust-lang.org/) toolchain
  * Cargo
  * `rustc`
  * [rust-analyzer](https://rust-analyzer.github.io/)
    * Could also be installed with [mason.nvim](https://github.com/williamboman/mason.nvim), and there is a commented out line in [`init.lua`](./init.lua) to do so, but installing as a part of your toolchain (`rustup compent add rust-analyzer`) helps to [avoid version inconsistencies](https://github.com/mrcjkb/rustaceanvim/blob/master/doc/mason.txt)
* A Java Development Kit
  * This project is built and developed on [OpenJDK](https://openjdk.org/) 21, but older or newer versions would likely work fine
  * Specifically, this project is built and developed on [`openjdk-21-jdk`](https://packages.ubuntu.com/noble/openjdk-21-jdk) from the Ubuntu 24.04 repositories
  * This project is not tested on Windows, but [Eclipse Temurin](https://adoptium.net/) is my go-to OpenJDK distribution on Windows
* A POSIX-compatible shell (provides `sh`), Bash, curl, wget, tar, gzip, and unzip
* Neovim 0.11.0 (built and used on [Neovim Unstable](https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable) on Ubuntu 24.04)

### Manual installation 
* Assumes `$XDG_CONFIG_HOME` == `~/.config`. Adjust accordingly if this is otherwise
* Assumes `~/.config/nvim` does not already exist. If it does, remove it (preferably with a backup) before installation
* Assumes that you have installed the [requirements](#requirements)

```bash
mkdir ~/.config
cd ~/.config
git clone https://github.com/RemasteredArch/nvim-config.git nvim/
```

### Automatic installation
* Designed for Ubuntu 24.04, but would probably work on other versions or other `apt`-based distributions
* This is currently COMPLETELY UNTESTED! Feel free to use it as a reference, but it is currently only a part of this repository in order to facilitate development
```bash
# Again, this is COMPLETELY untested!
curl https://raw.githubusercontent.com/RemasteredArch/nvim-config/main/setup.sh | bash
# DO NOT RUN THIS if you are not certain that it is okay!
```

## License

nvim-config is licensed under the GNU Affero General Public License version 3, or (at your option) any later version. You should have received a copy of the GNU Affero General Public License along with nvim-config, found in [LICENSE](./LICENSE). If not, see <[https://www.gnu.org/licenses/](https://www.gnu.org/licenses/)>.

nvim-config contains code from other software. See [COPYING.md](./COPYING.md) for more details.
