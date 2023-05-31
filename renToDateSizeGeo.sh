#!/bin/bash
# this script is to automatically convert a folder of video files to H.265
# You need to change SRC -- Source folder and DEST -- Destination folder

# Define the function
getDateTimeFromFilename() {
	local fn="$1"
	local dp="$2"

	# Extract the date and time using the pattern
	if [[ $fn =~ $dp ]]; then
		date="${BASH_REMATCH[1]}"
		time="${BASH_REMATCH[2]}"
		local fndate="$date"
		local fntime="$time"
	else
		local fndate="No match found."
		local fntime="No match found."
	fi
	# Assign the output parameters
	eval "$3='$fndate'"
	eval "$4='$fntime'"
}

checkDateValid() {

	local input="$1"
	if date -d "$input" >/dev/null 2>&1; then
  	#	echo "Die Zeichenkette ist ein gültiges Datum und eine gültige Zeit."
		return 0
	else
  	#	echo "Die Zeichenkette ist kein gültiges Datum und keine gültige Zeit."
		return 1
	fi
}


SRC=..
DEST=/data/photo-renamed

#which rdfind && echo da || apt install rdfind

ScriptDirName="$(
	cd "$(dirname "$0")"
	pwd -P
)"
ScriptName=$(basename "$0")
ScriptExtension=${ScriptName##*.}
ScriptName=${ScriptName%.*}

echo $ScriptDirName
echo $ScriptName
echo $ScriptExtension

mkdir -p "$DEST"
myFileList=$ScriptName.FileList.lst

cd "$SRC"
#if test `find $myFileList -mmin +5000`
if [ ! -f $myFileList ] || [ $(find $myFileList -mmin +5000) ]; then
	rm $myFileList.progress
	if [ 1 -eq 0 ]; then
		echo find images with type
		find . -name '*' -not -path '*/@eaDir/*' -exec file {} \; | grep -o -P '^.+: \w+ image' | pv -l | cut -f1 -d: >$myFileList.progress
		echo find videos with type
		find . -type f -not -path '*/@eaDir/*' -exec file -N -i -- {} + | grep video | pv -l | cut -f1 -d: >>$myFileList.progress
		echo find images and videos by extension
	else
		FILETYPES=("*.jpg" "*.jpeg" "*.png" "*.tif" "*.tiff" "*.gif" "*.xcf" "*.mp4" "*.avi" "*.mov" "*.wmv" "*.flv" "*.mkv" "*.webm" "*.m4v")
		for x in "${FILETYPES[@]}"; do
			echo -n "$x"
			find . -iname "$x" -print | grep -v @eaDir | pv -l >>$myFileList.progress
			#echo " " `wc -l filelist.lst | cut -d " " -f 1`
		done
	fi
	mv $myFileList.progress $myFileList
else
	echo $myFileList is young enough
fi

cat $ScriptName.FileList.lst | wc -l
endA=$(wc -l $ScriptName.FileList.lst | cut -d " " -f 1)
myA=1
while read FILE; 
do
	myA=$(( $myA + 1 ))
	filename=$(basename "$FILE")
	extension=${filename##*.}
	filename=${filename%.*}
	dirname=$(dirname "$FILE")
	IN="$SRC/$FILE"
	filename=$FILE
	echo --------------------------
	echo $endA/$myA DIR:$dirname $filename 
	dirname=$(dirname "$filename")
	filename=$(basename "$filename")

	# Extrahiere das Datum und die Zeit aus dem Dateinamen
	# yyyy-mm-dd--hh-mm-ss bla
	pattern="([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2}-[0-9]{2})"
	getDateTimeFromFilename "$filename" "$pattern" filenamedate filenametime
	# Access the output parameters
	if [[ $filenametime =~ "No match found." ]]; then
		# yyyy-mm-dd--hh-mm-ss bla
		# 2019-01-04--21-10 PRDI0011.jpeg
		pattern="([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2})"
		getDateTimeFromFilename "$filename" "$pattern" filenamedate filenametime
		if [[ $filenametime =~ "No match found." ]]; then
			#2019-01-04 13.05.12.copy.jpg
			pattern="([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}.[0-9]{2}.[0-9]{2})"
			getDateTimeFromFilename "$filename" "$pattern" filenamedate filenametime
			if [[ $filenametime =~ "No match found." ]]; then
				#2019-01-04 13.05.12.copy.jpg
				pattern="([0-9]{4}[0-9]{2}[0-9]{2})_([0-9]{2}[0-9]{2}[0-9]{2})"
				getDateTimeFromFilename "$filename" "$pattern" filenamedate filenametime
			fi
		fi
	fi
	# just in case
	filenametime=`echo $filenametime | tr - : `
	# extrahiere das create datum mit exiftool
	exifCreateD=`exiftool -CreateDate "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/' ` 
	exifDatTimOrg=`exiftool -DateTimeOriginal "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/' `
	exifModDat=`exiftool -ModifyDate "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed  's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/' `

	checkDateValid "$filenamedate $filenametime" && echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifCreateD"   && echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifDatTimOrg"   && echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifModDat"   && echo "Datum ok" || echo "Datum Bad"
 
	echo "filenamedate/time: $filenamedate $filenametime"
	echo "exifCreatD         $exifCreateD"
	echo "exifDatTimOrg      $exifDatTimOrg" 
	echo "exifModDat         $exifModDat"

OldestDate=`cat << EOF | sort | head -1 
$exifCreateD
$exifDatTimOrg 
$exifModDat
$filenamedate $filenametime
EOF`
	
Oldest2ndDate=`cat << EOF | sort | head -1 
$exifCreateD
$exifDatTimOrg 
$exifModDat
$filenamedate $filenametime
EOF`

	echo  ${#OldestDate} ${#Oldest2ndDate} 
	if [ ${#OldestDate} -le ${#Oldest2ndDate} ]; then
	    # echo "Die Variablen haben die gleiche Länge."
            echo .
	else
	    #echo "Die Variablen haben unterschiedliche Längen."
	    OldestDate=$Oldest2ndDate
	fi

	dimensions=$(exiftool -ImageWidth -ImageHeight -n -S "$FILE")
	width=$(echo "$dimensions" | awk -F ': ' '/ImageWidth/{print $2}')
	height=$(echo "$dimensions" | awk -F ': ' '/ImageHeight/{print $2}')
	exifSize=$(awk "BEGIN{ printf \"%.1f\", ($width * $height) / 1000000 }")
	echo "exifSize           $exifSize MPi"

	gps_data=$(exiftool -GPSLatitude -GPSLongitude -GPSAltitude -n -d "%+6f" "$FILE")
	if [ -n "$gps_data" ]; then
  		#echo "Das Bild enthält GPS-Daten."
		#echo $gps_data
		hasGeo="GEO"
		GPSLat=`exiftool -GPSLatitude -n -d "%+6f" "$FILE" | grep "GPS Latitude" | cut -d: -f2- | sed 's/^ *//'`
		GPSLon=`exiftool -GPSLongitude -n -d "%+6f" "$FILE" | grep "GPS Longitude" | cut -d: -f2- | sed 's/^ *//'`
		GPSAlt=`exiftool -GPSAltitude -n -d "%+6f" "$FILE"  | grep "GPS Altitude" | cut -d: -f2- | sed 's/^ *//'`
		echo $GPSLat
		echo $GPSLon
		echo $GPSAlt
	else
  		#echo "Das Bild enthält keine GPS-Daten."
		hasGeo="NoGeo"
  		# Weitere Aktionen für Bilder ohne GPS-Daten hier
	fi
	exiftool -XMP:all "$FILE"

	echo curl "https://nominatim.openstreetmap.org/reverse?format=json&lat=$GPSLat&lon=$GPSLon"
	curl "https://nominatim.openstreetmap.org/reverse?format=json&lat=$GPSLat&lon=$GPSLon"
	echo " "

	echo "-ufe-Old-Name=$filename" > tags.txt
	echo "-ufe-Old-Dir=$dirname" >>tags.txt
	echo "-ufe-Old-FileDat=$filenamedate $filenametime" >>tags.txt
        echo "-ufe-Old-exifCreatDat=$exifCreateD" >>tags.txt
        echo "-ufe-Old-exifDatTimOrg=$exifDatTimOrgD" >>tags.txt
        echo "-ufe-Old-exifModDat=$exifModDat" >>tags.txt

	OldestDateFile=`echo $OldestDate| tr ":" "-"`
	myNewFileName="$OldestDateFile -$hasGeo-"$exifSize"MPi.$extension" 
        echo -n myNewFileName
	thisDestDIR=$DEST/`echo myNewFilename  | cut -f1 -d" " | tr "-" "/"`
	mkdir -p $thisDestDIR
        echo cp  $myNewFileName $thisDestDIR
done <$ScriptName.FileList.lst
