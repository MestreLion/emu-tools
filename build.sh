#!/usr/bin/env bash
#
# Download and build all third-party projects
#
# Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
###############################################################################

set -Eeuo pipefail  # exit on any error
trap '>&2 echo "error: line $LINENO, status $?: $BASH_COMMAND"' ERR

SELF=${0##*/}
HERE=$(dirname "$(readlink -f "$0")")

VENDOR_ROOT=$HERE/vendor
BIN_DIR=$HERE/bin

#------------------------------------------------------------------------------

bold()    { tput bold; printf '%s' "$@"; tput sgr0; }
red()     { tput setaf 1; bold "$@"; }
green()   { tput setaf 2; bold "$@"; }
fatal()   { if (($#)); then { red "$@"; echo; } >&2; fi; exit 1; }
message() { green '* ' "$@"; echo; }
exists()  { type "$@" >/dev/null 2>&1; }
require() {
	local cmd=$1
	local pkg=${2:-$cmd}
	local msg='' eol=''
	if exists "$cmd"; then return; fi
	if [[ -x /usr/lib/command-not-found ]]; then
		/usr/lib/command-not-found -- "$cmd" || true
		eol='\n'
	else
		echo "Required command '${cmd}' is not installed." >&2
		if [[ "$pkg" != '-' ]]; then
			msg="with:\n\tsudo apt install ${pkg}\n"
		fi
	fi
	echo -e "Please install ${cmd} ${msg}and try again.${eol}" >&2
	exit 1
}
git_repo() {
	local url=$1
	local branch=${2:-master}
	local slug=${3:-$(basename "$url" .git)}

	local root=$VENDOR_ROOT/$slug

	if [[ -d "$root" ]]; then
		git -C "$root" fetch
		git -C "$root" checkout --quiet --force "$branch"
		git -C "$root" reset --quiet --hard origin/"$branch"
	else
		git clone -- "$url" "$root"
	fi

	cd "$root"
}

#------------------------------------------------------------------------------

require git

require cmake       # extract-xiso
require make        # extract-xiso
require gcc         # extract-xiso

message "extract-xiso: XBox ISO converter"
git_repo https://github.com/XboxDev/extract-xiso
mkdir -p build
cd build
rm -f CMakeCache.txt  # force re-generation if paths have changed
cmake ..
make
ln -srf extract-xiso -- "$BIN_DIR"

message "Done! Run 'source bin/activate' to add the tools to your $PATH"
