#! /bin/env bash

# Copyright © 2024 RemasteredArch
#
# This file is part of nvim-config.
#
# nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with nvim-config. If not, see <https://www.gnu.org/licenses/>.

{ # stops script from being executed if it isn't fully downloaded

declare -A dirs
dirs[script_source_dir]=$(dirname "$0")
dirs[xdg_config]="${XDG_CONFIG_HOME:-"$HOME/.config"}"
dirs[xdg_data]="${XDG_DATA_HOME:-"$HOME/.local/share"}"
dirs[temp_dir]=$(mktemp --directory -t nvim-config.setup.XXXXXXXX)
dirs[font_dir]="${dirs[xdg_data]}/fonts"

text_reset="\e[0m"
text_bold="\e[97m\e[100m\e[1m" # bold white text on a gray background


announce() {
  echo -e "\n$text_reset$text_bold$*$text_reset"
}

# Detect if a program or alias exists
has() {
  [ "$(type "$1" 2> /dev/null)" ]
}

echo "This script is designed and tested exlcusively for and with Ubuntu 24.04 (though it will likely work on other versions and other apt-based distributions), but it is distributed WITHOUT ANY FORM OF WARRANTY or guarantee of functionality, regardless of distribution or version"
echo
echo "setup.sh is a part of nvim-config. nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version."

lsb_release -i -s | grep -q Ubuntu || {
  echo "This script is designed for Ubuntu. Are you sure you want to continue?"
}


announce "Hit enter/return to continue or ^c/ctrl+c to quit."
read -r


announce "Updating"
sudo apt update && sudo apt upgrade


announce "Installing various packages"
declare -A packages
packages[required]="bash curl wget tar gzip git unzip openjdk-21-jdk g++ ninja-build cmake build-essentials" # it might start without some, but they are necessary for total use
packages[optional]="ripgrep fswatch"
packages[utils]="shellcheck" # though accessed and installed independently within nvim, shellcheck CLI provides more information
# shellcheck disable=SC2086
sudo apt install ${packages[required]} ${packages[optional]} ${packages[utils]}


announce "Installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash


announce "Installing node.js"
nvm install --lts


announce "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


announce "Installing rust-analyzer"
rustup component add rust-analyzer


announce "Installing Silicon"
packages[silicon_build_dependencies]="
  cmake             g++
  expat             libexpat1-dev
  pkg-config        libxml2-dev
  libfreetype6-dev  libfontconfig1-dev
  libharfbuzz-dev   libxcb-composite0-dev
  libssl-dev        libasound2-dev"

# shellcheck disable=SC2086
sudo apt install ${packages[silicon_build_dependencies]}
cargo install silicon


announce "Installing Caskaydia Cove Nerd Font"
cd "${dirs[temp_dir]}" || exit

wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
unzip CascadiaCode.zip

mkdir -p "${dirs[font_dir]}"
mv ./*.ttf "${dirs[font_dir]}"
# if the font isn't recognized, it might be necessary to install fontconfig and run fc-cache


announce "Adding the Neovim nightly PPA"
sudo add-apt-repository ppa:neovim-ppa/unstable \
&& sudo apt update


announce "Installing and updating Neovim"
sudo apt install neovim
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonInstallAll" +qa


announce "Updating again"
sudo apt update && sudo apt upgrade


announce "Setting up configs"
mkdir -p "${dirs[xdg_config]}"
ln -s "${dirs[script_source]}" "${dirs[xdg_config]}/nvim"


exit 0

} # stops script from being executed if it isn't fully downloaded
