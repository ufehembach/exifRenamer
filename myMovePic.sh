#!/usr/bin/env bash

ScriptDirName="$( cd "$(dirname "$0")" ; pwd -P )"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}


###############################################################################
#
FILETYPES=("*.jpg" "*.jpeg" "*.png" "*.tif" "*.tiff" "*.gif" "*.xcf")
#
WORKFOLDER=/data/photo
MOVETO=$WORKFOLDER-sorted"/Sorted/"
STAT=$WORKFOLDER-sorted"/Sorted.stat/"
MD5=$WORKFOLDER-sorted"/Sorted.md5/"
EXIF=$WORKFOLDER-sorted"/Sorted.exif/"

mkdir -p $MOVETO

cp $0 -p $WORKFOLDER-sorted
cd $WORKFOLDER/Old

mkdir -p $STAT
mkdir -p $MD5
mkdir -p $EXIF

#

movePic () 
{
 	filename=$(basename "$1")
   	extension=${filename##*.}
   	filename=${filename%.*}
   	myFileDateTime=`echo "$filename.$extension" | sed -e 's/\(.*\)--\(.*\)--\(.*\).$extension/\3/'`
	#   touch --date="$myFileDateTime" "$FILE"
	myFilename=`echo $filename | xargs | sed '0,/_/{s/_/--/}' `
   	myFileDATETIME=`echo $myFilename | sed -e 's/-x-/ /' | awk -F' '  '{print $1}'`
   	myFileDATE=`echo $myFileDATETIME | awk -F'--'  '{print $1}'`
   	myFileTIME=`echo $myFileDATETIME | awk -F'--'  '{print $2}'`
   	myTITLE=`echo $filename | sed -e 's/-x-/ /' | awk -F' '  '{out=""; for(i=2;i<=NF;i++){out=out" - "$i}; print out}' | cut -c 4-`
	myFileTIMEColon=`echo $myFileTIME | sed y/-/:/ | cut -d: -f1,2,3` 
	fileUDF=`date -d "$myFileDate $myFileTIMEColon" +%s`
	if [[ $fileUDF ]] 
	then
		true
	else
		myTITLE=$filename
	fi
 	DATETIMEexif=`grep "exif:DateTime:" "$EXIF/$1.exif" | awk -F' ' '{print $2" "$3}'`
 	DATETIMEcreate=`grep "date:create:" "$EXIF/$1.exif" | awk -F' ' '{print $2" "$3}'`
 	DATETIMEmodify=`grep "date:modify:" "$EXIF/$1.exif" | awk -F' ' '{print $2" "$3}'`
 	DATETIMEDigitized=`grep "exif:DateTimeDigitized:" "$EXIF/$1.exif" | awk -F' ' '{print $2" "$3}'`
 	DATETIMEOriginal=`grep "date:DateTimeOriginal:" "$EXIF/$1.exif" | awk -F' ' '{print $2" "$3}'`
	
	if [[ $DATETIMEexif ]] 
	then
   		myexifDATE=`echo $DATETIMEexif | awk -F' '  '{print $1}'`
   		myexifTIME=`echo $DATETIMEexif | awk -F' '  '{print $2}'`
		myexifDATESlash=`echo $myexifDATE | sed y/:/-/` 
		DATETIMEexif="${myexifDATESlash} ${myexifTIME}"
	fi
	if [[ $DATETIMEcreate ]] 
	then
		DATETIMEcreate=`echo $DATETIMEcreate | sed y/T/\ /` 
   		mycreateDATE=`echo $DATETIMEcreate | awk -F' '  '{print $1}'`
   		mycreateTIME=`echo $DATETIMEcreate | awk -F' '  '{print $2}'`
		mycreateDATESlash=`echo $mycreateDATE | sed y/:/-/` 
		DATETIMEcreate="${mycreateDATESlash} ${mycreateTIME}"
	fi
	if [[ $DATETIMEmodify ]] 
	then
		DATETIMEmodify=`echo $DATETIMEmodify | sed y/T/\ /` 
   		mymodifyDATE=`echo $DATETIMEmodify | awk -F' '  '{print $1}'`
   		mymodifyTIME=`echo $DATETIMEmodify | awk -F' '  '{print $2}'`
		mymodifyDATESlash=`echo $mymodifyDATE | sed y/:/-/` 
		DATETIMEmodify="${mymodifyDATESlash} ${mymodifyTIME}"
	fi
	if [[ $DATETIMEDigitized ]] 
	then
   		myDigitizedDATE=`echo $DATETIMEDigitized | awk -F' '  '{print $1}'`
   		myDigitizedTIME=`echo $DATETIMEDigitized | awk -F' '  '{print $2}'`
		myDigitizedDATESlash=`echo $myDigitizedDATE | sed y/:/-/` 
		DATETIMEDigitized="${myDigitizedDATESlash} ${myDigitizedTIME}"
	fi
	if [[ $DATETIMEOriginal ]] 
	then
   		myOriginalDATE=`echo $DATETIMEOriginal | awk -F' '  '{print $1}'`
   		myOriginalTIME=`echo $DATETIMEOriginal | awk -F' '  '{print $2}'`
		myOriginalDATESlash=`echo $myOriginalDATE | sed y/:/-/` 
		DATETIMEOriginal="${myOriginalDATESlash} ${myOriginalTIME}"
	fi
	todayUDF=`date -d ""  +%s`

	if [[ $DATETIMEexif ]] 
	then
		exifUDF=`date -d "$DATETIMEexif" +%s`
	else
		exifUDF="Nix"
	fi
	if [[ $DATTIMEcreate ]] 
	then
		createUDF=`date -d "$DATETIMEcreate" +%s`
	else
		createUDF="Nix"
	fi
	if [[ $DATETIMEmodify ]]
	then
		modifyUDF=`date -d "$DATETIMEmodify" +%s`
	else
		modifyUDF="Nix"
	fi
	if [[ $DATTIMEDigitized ]] 
	then
		DigitizedUDF=`date -d "$DATETIMEDigitized" +%s`
	else
		DigitizedUDF="Nix"
	fi
	if [[ $DATTIMEOriginal ]] 
	then
		OriginalUDF=`date -d "$DATETIMEOriginal" +%s`
	else
		OriginalUDF="Nix"
	fi
	echo exifUDF:   $exifUDF `date -d @$exifUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`
	echo createUDF: $createUDF `date -d @$createUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`
	echo modifyUDF: $modifyUDF `date -d @$modifyUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`
	echo fileUDF:   $fileUDF `date -d @$fileUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`
	echo DigitizedUDF: $DigitizedUDF `date -d @$DigitizedDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`
	echo OriginalUDF: $OriginalUDF `date -d @$OriginalUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null`

	echo $exifUDF exif `date -d @$exifUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` > $ScriptName.time
	echo $createUDF create `date -d @$createUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` >> $ScriptName.time
	echo $modifyUDF modify `date -d @$modifyUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` >> $ScriptName.time
	echo $fileUDF file `date -d @$fileUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` >> $ScriptName.time
	echo $DigitizedUDF Digitized `date -d @$DigitizedDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` >> $ScriptName.time
	echo $OriginalUDF Original `date -d @$OriginalUDF +%Y-%m-%d--%H-%M-%S 2> /dev/null` >> $ScriptName.time

	myMinTime=`grep -v Nix $ScriptName.time | sort -n | head -1`
   	myMinUDF=`echo $myMinTime | awk -F' '  '{print $1}'`
   	myMinWhat=`echo $myMinTime | awk -F' '  '{print $2}'`
   	myMinTime=`echo $myMinTime | awk -F' '  '{print $3}'`

	echo $myMinUDF
	echo $myMinWhat
	echo $myMinTime

	theDate=$myMinUDF

	if [[ "$fileUDF" != "$todayUDF" ]];
  	then
		theTITLE=$myTITLE
	else
		theTITLE=$filename
	fi

#	if [[ "$fileUDF" != "$todayUDF" ]];
#  	then
#		theTITLE=$myTITLE
#	else
#		theTITLE=$filename
#	fi
#	if [[ "$exifUDF" != "$todayUDF" && $exifUDF ]];
#	then
#		theDate=$exifUDF
#	else
#		if [[ "$createUDF" != "$todayUDF" &&  "$modifyUDF" != "$todayUDF" ]];
#		then
#			if [[ "$createUDF" > "$modifyUDF" ]];
#			then
#				theDate=$modifyUDF
#			else
#				theDate=$createUDF
#			fi
#		else
#			if [[ "$fileUDF" != "$todayUDF" ]];
#			then
#				 theDate=$fileUDF
#			else
#				theDate="nix"
#			fi
#		fi
#	fi 
 	if [[ "$theDate" != "nix" ]];
	then
		theDateFull=$(date -d @$theDate +%Y-%m-%d--%H-%M-%S)
		theSubDir=$(date -d @$theDate +%Y/%m/%d)
       		echo SUBDIR $theSubDir $theDateFull
	else
		theDateFull=""
		theSubDir="noExif"
	fi
	echo $theSubDir $theDateFull $theTITLE $extension
	NewFullFileName=${MOVETO}${theSubDir}/${theDateFull}" "${theTITLE}.${extension}
	echo OldName $1
	echo FullName ${NewFullFileName}
 	# mkdir -p "${MOVETO}$theSubDir" && mv -f "$1" "${MOVETO}$theSubDir"
	echo " Linking $1 to $NewFullFileName " >> $ScriptName.log
	cat $ScriptName.time  >> $ScriptName.log
	echo picked time $myMinUDF $myMinWhat $myMinTime  >> $ScriptName.log
	echo  "---------------------------------------------------------------------" >> $ScriptName.log

	mkdir -p "${MOVETO}${theSubDir}" 
	if [ -f "${NewFullFileName}" ]
	then
		echo "exists "
	#	cp  "$1" "$NewFullFileName"

	else
		echo  "ln $1" " --> " "$NewFullFileName"  
		ln  "$1" "$NewFullFileName"
	fi
}
#
###############################################################################
# Scanning (find) loop
# This is the normal loop that is run when the program is executed by the user.
# This runs find for the recursive searching, then find invokes this program with the two
# parameters required to trigger the above loop to do the heavy lifting of the sorting.
# Could probably be optimized into a function instead, but I don't think there's an
# advantage performance-wise. Suggestions are welcome at the URL at the top.
source ~/bar.lib.sh
echo -n count files " "
STARTTIME=`date +%Y-%m-%d-%H-%M-%S`
myEnd=0
rm filelist.lst
touch filelist.lst
for x in "${FILETYPES[@]}"; do
	echo -n "$x"
	find . -iname "$x" -print | grep -v @eaDir >> filelist.lst
	echo " " `wc -l filelist.lst | cut -d " " -f 1`
done
sort filelist.lst > filelist.sort
mv filelist.sort filelist.lst

#echo "./2000/12/09/2000-12-09--17-50-18-x-Schildgen, Nikolaus, Esstisch.jpg" > filelist.lst

myFile=`echo "$0" | sed -e's!/!-!g' | sed -e's!:!--!g' | sed -e's/~/+/' | sed -e's/@/#/'`
rm $myFile.lastrun
date > $myFile.lastrun 

myFile=0
endFile=`wc -l filelist.lst | cut -d " " -f 1`
myHour=`date +%H`

rm $ScriptName.log
touch $ScriptName.log

echo $endFile
while read filename
do
       	myFile=$(($myFile + 1))
       	# echo $myFile $endFile

  	if [ `date +%H` -ne $myHour ]
        then
                echo " " > mailbody.movePic.txt
                echo running in `pwd` >> mailbody.movePic.txt
                echo Started : $STARTTIME >> mailbody.movePic.txt
                echo Current : `date +%Y-%m-%d-%H-%M-%S` >> mailbody.movePic.txt
                echo "$0 $myFile/$endFile" >> mailbody.movePic.txt
                echo $subdir >> mailbody.movePic.txt
                tail -10 ~/$0.log >> mailbody.movePic.txt
                cat mailbody.movePic.txt | mail -s "$0 $myFile/$endFile" ufe@hembach-1.de
                myHour=`date +%H`
        fi

	if [ $myFile -ge $endFile ]
	then
		endFile=$(($myFile+1))
	fi
       	lib_progress_bar $myFile $endFile
        echo "$0 $myFile/$endFile" 
	echo  "${filename}"
	MD5File=$MD5/${filename}.md5 
	mkdir -p "${MD5File%/*}"
	if [ ! -e "${MD5File}" -o "${MD5File}" -ot "${filename}" ] 
	then
		md5sum "${filename}" > "${MD5File}.tmp"
		mv "${MD5File}.tmp" "${MD5File}"
	fi	
	EXIFFile=$EXIF/${filename}.exif
	mkdir -p "${EXIFFile%/*}"
	if [ ! -e "${EXIFFile}" -o "${EXIFFile}" -ot "${filename}" ] 
	then
		identify -verbose "${filename}" > "${EXIFFile}.tmp"
		mv "${EXIFFile}.tmp" "${EXIFFile}"
	fi	
 	HARDLINK=`stat --printf='%h' "${filename}"`
	#if [ $HARDLINK -ne 2 ] 
	if [ $HARDLINK -ne 5 ] 
	then	
		echo process "${filename}"
		movePic "${filename}"
	else
		echo ${filename} already double linked"!"
	fi
	echo  "*********************************************************************"
done < ./filelist.lst

# clean up empty directories. Find can do this easily.
# Remove Thumbs.db first because of thumbnail caching
echo -n "Removing Thumbs.db files ... "
find . -name Thumbs.db -delete
echo "done."
echo -n "Cleaning up empty directories ... "
find . -empty -delete
echo "done."
