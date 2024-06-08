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

# update.sh: an in-development and untested script to update Neovim packages

text_reset="\e[0m"
text_bold="\e[97m\e[100m\e[1m" # bold white text on a gray background


announce() {
  echo -e "\n$text_reset$text_bold$*$text_reset"
}


announce "Updating Neovim: Lazy packages"
nvim --headless "+Lazy! sync" +qa

announce "Updating Neovim: Mason packages"
nvim --headless "+MasonInstallAll" +qa

announce "Updating Neovim: Treesitter packages"
nvim --headless "+TSUpdateSync" +qa # not sure if this will block properly


exit 0
