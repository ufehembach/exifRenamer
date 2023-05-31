#!/bin/bash
# this script is to automatically convert a folder of video files to H.265
# You need to change SRC -- Source folder and DEST -- Destination folder

SRC="/data/photo-org/Sorted/0000"
DEST=/data/photo.__CLOUDSYNC_ENC

badText="__CLOUDSYNC_ENC_"

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

mkdir -p "$DEST"

cd "$SRC"

#find . -path "*/@eaDir/*" -prune -o -print -exec file {} \; | grep -o -P '^.+: \w+ image' | cut -d: -f1  > $ScriptName.FileList.lst
find . -type f > $ScriptName.FileList.lst

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
   #identify -verbose "$IN" 2>&1 | grep "corrupt image"
   firstText=`head -1  "$IN" | cut -c1-16`
   if [ $firstText == $badText ]
   then
   	myBAD=$(($myBAD + 1))
	mkdir -p "$DEST/$dirname/"
	mv "$FILE" "$DEST/$dirname/$filename.imac.$extension"
   else
   	myGOOD=$(($myGOOD + 1))
   fi
   echo Total:$myA BAD:$myBAD GOOD:$myGOOD DIR:$dirname
done < $ScriptName.FileList.lst
