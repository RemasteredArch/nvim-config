#! /usr/bin/env bash

# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Copyright © 2024-2025 RemasteredArch
#
# This file is part of nvim-config.
#
# nvim-config is free software: you can redistribute it and/or modify it under the terms of the GNU
# Affero General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# nvim-config is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with nvim-config.
# If not, see <https://www.gnu.org/licenses/>.

# Perform the actual install process in a subshell to avoid setting variables in the host. Also has
# the effect of not allowing the sensitive parts of this script to execute without the whole script
# being downloaded.
(
    set -euo pipefail

    declare -A dirs
    dirs[script_source]=$(dirname "$0")
    dirs[xdg_config]="${XDG_CONFIG_HOME:-"$HOME/.config"}"
    dirs[xdg_data]="${XDG_DATA_HOME:-"$HOME/.local/share"}"
    dirs[temp_dir]=$(mktemp --directory -t nvim-config.setup.XXXXXXXX)
    dirs[font_dir]="${dirs[xdg_data]}/fonts"
    dirs[nvim]="${dirs[xdg_config]}/nvim"

    config_repository='https://github.com/RemasteredArch/nvim-config'

    text_reset="\e[0m"
    text_strong="\e[97m\e[100m\e[1m" # Bold white text on a gray background.

    announce() {
        echo -e "\n$text_reset$text_strong$*$text_reset"
    }

    # Detect if program(s) or alias(es) exist.
    has() {
        [ "$(type "$@" 2> /dev/null)" ]
    }

    # Detect if a font exists.
    has_font() {
        has "fc-list" || "${maybe_sudo[@]}" apt install 'fontconfig'

        fc-list | grep --quiet "$@"
    }

    # Get the minimum value of two integers.
    min() {
        local a="$1"
        local b="$2"

        echo "$((a < b ? a : b))"
    }

    # Get the width of the terminal, up to a maximum of 75 columns.
    terminal_width() {
        min 75 "$(tput cols)"
    }

    print_folded() {
        fold --spaces --width "$(terminal_width)"
    }

    install_node() {
        announce 'Installing nvm'

        curl --fail --location 'https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh' | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

        announce 'Installing latest Node.js LTS'
        nvm install --lts
    }

    install_nvim() {
        announce 'Installing the bob version manager'
        cargo install bob-nvim

        announce 'Installing Neovim nightly'
        bob use nightly
        export PATH="${dirs[xdg_data]}/bob/nvim-bin:$PATH"

        announce 'Installing plugins and packages'
        echo '<Skipped to avoid a segfault>'
        # nvim --headless '+Lazy! sync' +qa
        # nvim --headless '+MasonInstallAll' +qa
        # nvim --headless '+TSInstallAll' +qa
    }

    parse_neovim_version() {
        # Extract the version number, matching on either a number like `v0.12.0` or a number like
        # `v0.12.0-dev-1234+gff777f9a8`. Strips all other text from the matching line and uses `-n`
        # and `/p` print only the matching lines, then returns only the first matching line.
        sed -n 's/.*NVIM \(v[0-9]\+.[0-9]\+.[0-9]\+\(-dev-[0-9]\++[a-z0-9]\+\)\?\).*/\1/p' \
            | head -n 1
    }

    declare -a maybe_sudo=('sudo')
    ! has 'sudo' && maybe_sudo=()
    do_os_check='true'

    for opt in "$@"; do
        case "$opt" in
            '--no-sudo')
                maybe_sudo=()
                ;;
            '--no-os-check')
                do_os_check='false'
                ;;
        esac
    done

    [ "$do_os_check" = 'true' ] && {
        has 'lsb_release' || {
            "${maybe_sudo[@]}" apt-get update -qq &> /dev/null
            "${maybe_sudo[@]}" apt-get install -qq 'lsb-release' &> /dev/null
        }

        lsb_release -i -s | grep -q Ubuntu || {
            echo
            echo 'This script is designed for Ubuntu. Are you sure you want to continue?'
        }
    }

    print_folded << EOF
This script is designed and tested exlcusively for and with Ubuntu 24.04 (though it will likely \
work on other versions and other apt-based distributions), but it is distributed WITHOUT ANY FORM \
OF WARRANTY or guarantee of functionality, regardless of distribution or version.

setup.sh is a part of nvim-config. nvim-config is free software: you can redistribute it and/or \
modify it under the terms of the GNU Affero General Public License as published by the Free \
Software Foundation, either version 3 of the License, or (at your option) any later version.
EOF

    announce 'Hit enter/return to continue or ^c/ctrl+c to quit.'
    read -r

    announce 'Updating'
    "${maybe_sudo[@]}" apt update && "${maybe_sudo[@]}" apt upgrade

    announce 'Installing various packages'
    declare -A packages
    # Neovim might start without some of these, but they are necessary for a complete setup.
    packages[required]='
            bash
            build-essential
            cmake
            curl
            g++
            git
            golang
            gzip
            ninja-build
            openjdk-21-jdk
            python3
            python3-venv
            ripgrep
            tar
            unzip
            wget
        '
    packages[optional]='
            fd-find
            inotify-tools
        '

    # shellcheck disable=SC2086
    "${maybe_sudo[@]}" apt install ${packages[required]} ${packages[optional]}

    if has 'node'; then
        echo -n "Node.js version $(node --version) is already installed. Install latest LTS with nvm anyways? (y/n): "
        read -rn 1 answer
        echo

        [ "$answer" = 'y' ] && {
            install_node
        }
    else
        install_node
    fi

    has 'cargo' || {
        announce "Installing Rust"
        curl --proto '=https' --tlsv1.2 --fail --silent --show-error 'https://sh.rustup.rs' | sh
        . "$HOME/.cargo/env"
    }

    has 'rust-analyzer' || {
        announce 'Installing rust-analyzer'
        rustup component add rust-analyzer
    }

    has 'silicon' || {
        announce 'Installing Silicon'
        packages[silicon_build_dependencies]="
                cmake             g++
                expat             libexpat1-dev
                pkg-config        libxml2-dev
                libfreetype6-dev  libfontconfig1-dev
                libharfbuzz-dev   libxcb-composite0-dev
                libssl-dev        libasound2-dev"

        # shellcheck disable=SC2086
        "${maybe_sudo[@]}" apt install ${packages[silicon_build_dependencies]}
        cargo install silicon
    }

    has_font 'Noto Color Emoji' || "${maybe_sudo[@]}" apt install 'fonts-noto-color-emoji'

    has_font 'CaskaydiaCove' || {
        announce 'Installing Caskaydia Cove Nerd Font'
        cd "${dirs[temp_dir]}" || exit

        curl --fail --silent --show-error --location --output 'CascadiaCode.zip' \
            'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip'
        unzip 'CascadiaCode.zip'

        mkdir -p "${dirs[font_dir]}"
        mv ./*.ttf "${dirs[font_dir]}"
        # If the font isn't recognized, it might be necessary to run `fc-cache` (added by
        # `sudo apt install fontconfig`).
    }

    announce 'Setting up configs'
    if [ -d "${dirs[nvim]}" ]; then
        if [ "${dirs[script_source]}" != "${dirs[nvim]}" ]; then
            print_folded << EOF
Neovim configuration (directory \`${dirs[nvim]}\`) already exists. Make sure it points to this \
config, or override it with \`NVIM_APPNAME\`.
EOF
        fi
    else
        mkdir -p "${dirs[xdg_config]}"

        # If `.git/` exists, assume that the user `git clone`'d this config's repository, in which
        # case it should be symlinked, otherwise it should be `git clone`'d into place.
        if [ -d "${dirs[script_source]}/.git" ]; then
            ln -s "${dirs[script_source]}" "${dirs[nvim]}"
        else
            git clone "$config_repository" "${dirs[nvim]}"
        fi

    fi

    if has 'nvim'; then
        echo "$SHELL"

        local_nvim_version="$(nvim --version | parse_neovim_version)"
        latest_nvim_nightly_version="$(
            curl --fail --silent --show-error --location \
                --header 'Accept:application/json' \
                'https://api.github.com/repos/neovim/neovim/releases/tags/nightly' \
                | parse_neovim_version
        )"

        print_folded << EOF
Neovim version $local_nvim_version is already installed. This config expects the latest nightly \
version (currently $latest_nvim_nightly_version).
EOF
        echo -n 'Install latest nightly with bob-nvim? (y/n): '
        read -rn 1 answer
        echo

        [ "$answer" = 'y' ] || {
            install_nvim
        }
    else
        install_nvim
    fi

    announce 'All done!'
    echo "Please make sure that your terminal emulator is using a Nerd Font."

    exit 0
)

# Outside of the subshell, set the relevant environment variables again. These should have been
# set be the relevant tools already using Bash's configuration files, but setting these again
# allows the host to start Neovim without launching a new shell.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
export PATH="${XDG_DATA_HOME:-"$HOME/.local/share"}/bob/nvim-bin:$PATH"
. "$HOME/.cargo/env"
