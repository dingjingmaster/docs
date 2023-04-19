#!/bin/bash

curdir=$(dirname $(dirname $(realpath -- $0)))
latexDir="${curdir}/latex"
curDocDir="${1}"
curDocDirPath="${curdir}/docs/${curDocDir}"
targetDocDir="${latexDir}/${curDocDir}"


[[ $# -ne 1 ]] && echo "Missing parameter" && exit 1
[[ ! -d "${curDocDirPath}" ]] && echo "dir ${curDocDirPath} not exists" && exit 1
[[ ! -d ${latexDir} ]] && echo "mkdir -p ${latexDir}" && mkdir -p "$latexDir"
[[ ! -d "${targetDocDir}" ]] && echo "mkdir -p ${targetDocDir}" && mkdir -p "${targetDocDir}"

echo "${curdir}/$1"

for f in "${curDocDirPath}/*"
do
    fileName=$(basename $(realpath -- "$f"))
    mdFile=${curDocDirPath}/$fileName
    latexFile=${targetDocDir}/${fileName/.md/.tex}
    echo "$mdFile --> $latexFile"
    bash -c "${curdir}/bin/pandoc-warp.sh \"${mdFile}\" \"${latexFile}\""
done

#pandoc --listings -s -f markdown -t latex -o "$2" "$1" --pdf-engine=xelatex -V mainfont="Source Han Mono SC"
