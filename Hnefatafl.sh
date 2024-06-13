#!/bin/sh
echo -ne '\033c\033]0;Hnefatafl\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Hnefatafl.x86_64" "$@"
