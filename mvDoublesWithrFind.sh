#!/bin/bash
# this script is to automatically convert a folder of video files to H.265
# You need to change SRC -- Source folder and DEST -- Destination folder

SRC=/home/ufe/Bilder/photo/2005
DEST=/home/ufe/Bilder/photo-dedups/2005

badText="__CLOUDSYNC_ENC_"

which rdfind && echo da || apt install rdfind

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

mkdir -p "$DEST"

cd "$SRC"

rm results.txt

rdfind .

cat results.txt | grep DUPTYPE_WITHIN_SAME_TREE | cut -d" " -f 8- > $ScriptName.FileList.lst  

cat $ScriptName.FileList.lst | wc -l
endA=`wc -l $ScriptName.FileList.lst | cut -d " " -f 1`

while read FILE
do
   myA=$(($myA + 1))
   filename=$(basename "$FILE")
   extension=${filename##*.}
   filename=${filename%.*}
   dirname=$(dirname "$FILE") 
   IN="$SRC/$FILE"
   mkdir -p "$DEST/$dirname"
   mv "$FILE" "$DEST/$FILE"
   echo $endA/$myA DIR:$dirname
done < $ScriptName.FileList.lst
