#!/bin/sh

#    verilog-cleaner, a shell script to lint and format Verilog code.
#    Copyright (C) 2021  Hu Jialun (SuibianP)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


cd "${GITHUB_WORKSPACE-.}/${INPUT_WORKDIR}" || exit
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

###### verilator ######
command -v verilator \
|| alias verilator='docker run -ti -v ${PWD}:/work --user $(id -u):$(id -g) verilator/verilator:latest'
# sudo apt-get install verilator

###### verible ######
command -v verible-verilog-lint \
    || curl -s https://api.github.com/repos/chipsalliance/verible/releases/latest \
    | grep -oP '\s*"browser_download_url":\s*"\K.*linux-static-x86_64.*(?=")' \
    | xargs curl -L | sudo tar xzf - -h --strip-components 1 -C /

reviewdog -reporter=${INPUT_REPORTER-local} -diff='git diff' -runners=${INPUT_RUNNERS} -conf=${ACTION_PATH-.}/.reviewdog.yml ${DEBUG:+-tee}
