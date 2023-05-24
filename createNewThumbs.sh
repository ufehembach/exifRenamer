#!/bin/bash
# 

myNConvert=/data/photo/__Apps/NConvert/nconvert 
which $myNConvert && echo da || { echo you need nconvert at $myNConvert ; exit ; }

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

myFileList=$ScriptName.lst
find . -name '*' -not -path '*/@eaDir/*' -exec file {} \; | grep -o -P '^.+: \w+ image' | cut -f1 -d: > $myFileList
endA=`cat $myFileList | wc -l`
while read FILE
do
   filename=$(basename "$FILE")
   extension=${filename##*.}
   filename=${filename%.*}
   dirname=$(dirname "$FILE")
   echo $endA/$myA $FILE
   #$myNConvert -overwrite -buildexifthumb "$FILE"
   $myNConvert -overwrite -buildexifthumb "$FILE"
   myA=$(($myA + 1))
done < $myFileList


