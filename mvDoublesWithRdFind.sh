#!/bin/bash
# this script is to automatically convert a folder of video files to H.265
# You need to change SRC -- Source folder and DEST -- Destination folder

which figlet && echo da || apt install figlet
which rdfind && echo da || apt install rdfind

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

#SRC=/home/ufe/Bilder/photo/2005
#DEST=/home/ufe/Bilder/photo-dedups/2005

SRC=$ScriptDirName
SRC=`pwd`
DST=$ScriptDirName-deduplicated-photos
DST=$SRC-deduplicated-photos

figlet -w 120 $SRC
echo ---------------------------------------------
echo $DST

mkdir -p "$DST"

cd "$SRC"

RESULTSFILE=results.txt
myFileList=$RESULTSFILE
if [ ! -f $myFileList ] || [ `find $myFileList -mmin +5000` ]
then
	#rm $myFileList.progress
	rm $myFileList
	rdfind .
	#mv $myFileList.progress $myFileList
else
    echo $myFileList is young  enough
fi


cp $RESULTSFILE results.`date -I`.txt
cat $RESULTSFILE | grep DUPTYPE_WITHIN_SAME_TREE | cut -d" " -f 8- > $ScriptName.FileList.lst  

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
   mkdir -p "$DST/$dirname"
   mv "$FILE" "$DST/$FILE"
   echo $endA/$myA DIR:$dirname
done < $ScriptName.FileList.lst
