#!/bin/bash
# this script is to automatically convert a folder of video files to H.265
# You need to change SRC -- Source folder and DEST -- Destination folder

SRC=/volume3/photo
DEST=/volume3/photo.kaputt

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

mkdir -p "$DEST"

cd "$SRC"

find . -path "*/@eaDir/*" -prune -o -print -exec file {} \; | grep -o -P '^.+: \w+ image' | cut -d: -f1  > $ScriptName.FileList.lst

cat $ScriptName.FileList.lst | wc -l
endA=`wc -l $ScriptName.FileList.lst | cut -d " " -f 1`

while read FILE
do
   myA=$(($myA + 1))
   filename=$(basename "$FILE")
   extension=${filename##*.}
   filename=${filename%.*}
   IN="$SRC/$FILE"
   identify -verbose "$IN" 2>&1 | grep "corrupt image"
done < $ScriptName.FileList.lst
