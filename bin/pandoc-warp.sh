#!/bin/bash

[[ $# -ne 2 ]] && echo "Missing parameter" && exit 1
[[ ! -f $1 ]] && echo "$1 not exists" && exit 1

pandoc --listings -s -f markdown -t latex -o "$2" "$1" --pdf-engine=xelatex -V mainfont="Source Han Mono SC"
