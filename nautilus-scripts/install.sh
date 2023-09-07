#!/bin/bash

folder=${1:-'⟹ Emulator'}

self=${0##*/}
here=$(dirname "$(readlink -f "$0")")
scripts=${XDG_DATA_HOME:-$HOME/.local/share}/nautilus/scripts/$folder

mkdir -pv -- "$scripts"
rsync -rv --exclude "$self" "$here"/ "${scripts%/}"/
echo "*" > "$scripts"/.gitignore
