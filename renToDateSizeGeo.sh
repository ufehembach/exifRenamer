#!/bin/bash
# this script is to automatically renames all images to a date-time-resolution-geo filename
# You need to change SRC -- Source folder and DEST -- Destination folder

# Define the function
getDateTimeFromFilename() {
	local text="$1"
	local pattern="$2"

	if [[ $text =~ $pattern ]]; then
  		match="${BASH_REMATCH[0]}"
  		echo "Übereinstimmung: $match"
		local filenamedatetime="$match"
	else
  		echo "Keine Übereinstimmung gefunden"
		local filenamedatetime="No match found."
	fi
	return
	# Extract the date and time using the pattern
	#substring="${fn:0:22}"
	match=$(echo "$fn" | grep -o -m 1 -P "$dp")
	echo $match
	echo ----
	echo $match | head -1
	echo .....
	#if [[ "$substring" =~ "$dp" ]]; then
	if [[ "$match" =~ "$dp" ]]; then
		datetime="${BASH_REMATCH[0]}"
		#time="${BASH_REMATCH[1]}"
		#local fndate="$date"
		#local fntime="$time"
		local filenamedatetime="$datetime"
	else
		#local fndate="No match found."
		#local fntime="No match found."
		local filenamedatetime="No match found."
	fi
	# Assign the output parameters
	eval "$3='$datetime'"
	#eval "$3='$fndate'"
	#eval "$4='$fntime'"
}

checkDateValid() {

	local input="$1"
	if [[ -n "$input" ]]; then
		if [[ -z "$input" ]]; then
			date -d "$input"
		fi
	fi
	if [[ -n "$input" ]] && [[ -z "$input" ]] && date -d "$input" >/dev/null 2>&1; then
		#		echo "Die Zeichenkette ist ein gültiges Datum und eine gültige Zeit."
		return 0
	else
		#echo "Die Zeichenkette ist kein gültiges Datum und keine gültige Zeit."
		return 1
	fi
}

SRC=../
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
myFileCSV=$DEST/$ScriptName.FileList.csv

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
			pwd
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
myA=0
while read FILE; do
	filename=$(basename "$FILE")
	extension=${filename##*.}
	filename=${filename%.*}
	dirname=$(dirname "$FILE")
	IN="$SRC/$FILE"
	filename=$FILE
	dirname=$(dirname "$filename")
	filename=$(basename "$filename")
	flenamedatetime=""
	exifCreatD=""
	exifDatTimOrg=""
	exifModDat=""

	myA=$(($myA + 1))
	dd if=/dev/urandom count=$myA bs=1 2>/dev/null | pv -f -p -w 40 -s $endA >/dev/null
	echo -n -------$filename-------------------
	#echo $endA/$myA DIR:$dirname $filename
	if [ -s "$FILE" ]; then
		# 	echo "Die Datei ist nicht leer."
		true
	else
		echo "Die Datei ist leer."
		continue
	fi

	# Extrahiere das Datum und die Zeit aus dem Dateinamen
	# yyyy-mm-dd--hh-mm bla
	# 2019-01-04--21-10 PRDI0011.jpeg
	pattern="([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2})"
	getDateTimeFromFilename "$filename" "$pattern" filenamedatetime # filenametime
	# Access the output parameters
	if [[ $filenamedatetime =~ "No match found." ]]; then
		# yyyy-mm-dd--hh-mm-ss bla
		pattern="([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2}-[0-9]{2})"
		getDateTimeFromFilename "$filename" "$pattern" filenamedatetime # filenametime
		if [[ $filenamedatetime =~ "No match found." ]]; then
			#2019-01-04 13.05.12.copy.jpg
			pattern="([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}.[0-9]{2}.[0-9]{2})"
			getDateTimeFromFilename "$filename" "$pattern" filenamedatetime # filenametime
			if [[ $filenamedatetime =~ "No match found." ]]; then
				#2019-01-04_130512copy.jpg
				pattern="([0-9]{4}[0-9]{2}[0-9]{2})_([0-9]{2}[0-9]{2}[0-9]{2})"
				getDateTimeFromFilename "$filename" "$pattern" filenamedatetime # filenametime
			fi
			if [[ $filenamedatetime =~ "No match found." ]]; then
				# 2000-12-09--18-42
				pattern="([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2})"
				getDateTimeFromFilename "$filename" "$pattern" filenamedatetime # filenametime
			fi
		fi
	fi
	# just in case
	filenamedatetime=$(echo $filenamedatetime | tr - :)
	if [[ $filenamedatetime == "No match found." ]]; then
		filenamedatetime=""	
	fi
	# extrahiere das create datum mit exiftool
	exifCreateD=$(exiftool -CreateDate "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/')
	exifDatTimOrg=$(exiftool -DateTimeOriginal "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/')
	exifModDat=$(exiftool -ModifyDate "$FILE" | cut -f2- -d: | sed 's/^ *//' | sed 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/')

	checkDateValid "$filenamedatetime" #&& echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifCreateD"      #&& echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifDatTimOrg"    #&& echo "Datum ok" || echo "Datum Bad"
	checkDateValid "$exifModDat"       #&& echo "Datum ok" || echo "Datum Bad"

	echo ""
	echo "filenamedate/time: $filenamedatetime"
	echo "exifCreatD         $exifCreateD"
	echo "exifDatTimOrg      $exifDatTimOrg"
	echo "exifModDat         $exifModDat"
	OldestDate=$(
		cat <<EOF | sed '/^\s*$/d' | sort | head -1 | xargs
$exifCreateD
$exifDatTimOrg 
$exifModDat
$filenamedatetime
EOF
	)

	Oldest2ndDate=$(
		cat <<EOF | sed '/^\s*$/d' | sort | head -1 | xargs
$exifCreateD
$exifDatTimOrg 
$exifModDat
$filenamedatetime
EOF
	)

	#echo  ${#OldestDate} ${#Oldest2ndDate}
	if [ ${#OldestDate} -le ${#Oldest2ndDate} ]; then
		# echo "Die Variablen haben die gleiche Länge."
		true
	else
		#echo "Die Variablen haben unterschiedliche Längen."
		OldestDate=$Oldest2ndDate
	fi

	dimensions=$(exiftool -ImageWidth -ImageHeight -n -S "$FILE")
	width=$(echo "$dimensions" | awk -F ': ' '/ImageWidth/{print $2}')
	height=$(echo "$dimensions" | awk -F ': ' '/ImageHeight/{print $2}')
	exifSize=$(awk "BEGIN{ printf \"%.1f\", ($width * $height) / 1000000 }")
	#echo "exifSize           $exifSize MPi"

	gps_data=$(exiftool -GPSLatitude -GPSLongitude -GPSAltitude -n -d "%+6f" "$FILE")
	if [ -n "$gps_data" ]; then
		#echo "Das Bild enthält GPS-Daten."
		#echo $gps_data
		hasGeo="GEO"
		GPSLat=$(exiftool -GPSLatitude -n -d "%+6f" "$FILE" | grep "GPS Latitude" | cut -d: -f2- | sed 's/^ *//')
		GPSLon=$(exiftool -GPSLongitude -n -d "%+6f" "$FILE" | grep "GPS Longitude" | cut -d: -f2- | sed 's/^ *//')
		GPSAlt=$(exiftool -GPSAltitude -n -d "%+6f" "$FILE" | grep "GPS Altitude" | cut -d: -f2- | sed 's/^ *//')
		#echo $GPSLat
		#echo $GPSLon
		#echo $GPSAlt
	else
		#echo "Das Bild enthält keine GPS-Daten."
		hasGeo="NoGeo"
		# Weitere Aktionen für Bilder ohne GPS-Daten hier
	fi
	#exiftool -XMP:all "$FILE"
	if [ $hasGeo = "GEO" ]; then
		json=""
		#echo curl "https://nominatim.openstreetmap.org/reverse?format=json&lat=$GPSLat&lon=$GPSLon"
		json=$(curl -s "https://nominatim.openstreetmap.org/reverse?format=json&lat=$GPSLat&lon=$GPSLon")
		#echo $json
		#	"county":"Landkreis Sigmaringen"
		#	"state":"Baden-Württemberg",
		#	"ISO3166-2-lvl4":"DE-BW",
		#	"country_code":"de"
		licence=$(echo "$json" | jq -r '.license')
		#echo "$license"
		display_name=$(echo "$json" | jq -r '.display_name')
		#echo "$display_name"
		village=$(echo "$json" | jq -r '.address.village')
		#echo "$village"
		muncipality=$(echo "$json" | jq -r '.address.muncipality')
		#echo "$muncipality"
		county=$(echo "$json" | jq -r '.address.county')
		#echo "$county"
		country_code=$(echo "$json" | jq -r '.address.country_code')
		#echo "$country_code"
		suburb=$(echo "$json" | jq -r '.address.suburb')
		#echo "$suburb"
		iso3166=$(echo "$json" | jq -r '.address."ISO3166-2-lvl4"')
		#echo "$iso3166"
		myGeo=$(echo "$iso3166"+"$county"+"$suburb")
		if [ -n "$myGeo" ]; then
			hasGeo="$myGeo"
			#		echo "$hasGeo"
		fi
	fi

	echo "::"$OldestDate"::"
	if [[ -n "$OldestDate" ]]; then
		#	echo do-it
		echo "ufe-Old-Name=$filename" >tags.txt
		echo "ufe-Old-Dir=$dirname" >>tags.txt
		echo "ufe-Old-FileDat=$filenamedate $filenametime" >>tags.txt
		echo "ufe-Old-exifCreatDat=$exifCreateD" >>tags.txt
		echo "ufe-Old-exifDatTimOrg=$exifDatTimOrgD" >>tags.txt
		echo "ufe-Old-exifModDat=$exifModDat" >>tags.txt
		echo "ufe-geo=$hasGeo" >>tags.txt

		OldestDateFile=$(echo $OldestDate | tr ":" "-" | tr " " "-")
		#	echo $OldestDatFile
		myNewFileName="$OldestDateFile-$hasGeo-"$exifSize"MPi.$extension"
		myNewFilename=$(echo "$myNewFileName" | tr ":" "-")
		#	echo "$myNewFileName"
		# create folder if not exists
		thisDestDIR=$DEST/$(echo "$myNewFilename" | cut -c 1-10 | tr "-" "/")
		mkdir -p $thisDestDIR
		# verify if file is already existing, if so add index.
		myIndex=1
		while [ -f "$thisDestDIR"/"$myNewFilename" ]; do
			myNewFileName="$OldestDateFile-$hasGeo-"$exifSize"MPi.$myIndex.$extension"
			myNewFilename=$(echo "$myNewFileName" | tr ":" "-")
			#			echo "$myNewFileName"
			myIndex=$(($myIndex + 1))
		done
		echo "$thisDestDIR"/"$myNewFileName"
		cp "$FILE" "$thisDestDIR"/"$myNewFileName"
		#		cat tags.txt
		exiftool -overwrite_original -tagsFromFile tags.txt "$thisDestDIR"/"$myNewFileName"
		{
			echo "------$(date -I)"--------
			echo "$FILE"
			echo ".......tags.txt---------"
			cat tags.txt
			echo "............GEO---------"
			echo "$license"
			echo "$display_name"
			echo "$village"
			echo "$muncipality"
			echo "$county"
			echo "$country_code"
			echo "$suburb"
			echo "$iso3166"

			echo " "
			echo $myGeo

			echo ----------json------------
			echo $json
			echo ----------exiftool-------
			exiftool "$FILE"
			echo ----------csv------------
			echo \"$myA/$endA\"\;\"$filename\"\;\"$exifSizeMPi\"\;\"$hasGeo\"\;\"$county\"\;\"$country_code\"\;\"$subburb\"\;\"$village\"\;\"$muncipality\"\;\"$iso3166\"\;\"$display_anme\"\;\"$dirname\"\;\"$FILE\"\;\"$filenamedatetime\"\;\"$exifCreateD\"\;\"$exifDatTimOrgD\"\;\"$exifModDat\"\;\"$OldesDateFile\"\;\"$Oldest2ndDate\" >>$myFileCSV
			echo ----------`date`------------
		} >"$thisDestDIR"/"$myNewFileName.info.txt"
	else
		echo dont-do-it
	fi
	if [ $myA = 1 ]; then
		echo "count;Name;MPi;GEO;county;country_code;suburb;village;muncipality;iso3166;display_name;DIR;FILE;OldFileDat;Old-exifCreateDat;Old-exitDatTimOrg;old-exifModDat;OldestDateFile;Oldest2ndDate" >$myFileCSV
	fi
	echo \"$myA/$endA\"\;\"$filename\"\;\"$exifSizeMPi\"\;\"$hasGeo\"\;\"$county\"\;\"$country_code\"\;\"$subburb\"\;\"$village\"\;\"$muncipality\"\;\"$iso3166\"\;\"$display_anme\"\;\"$dirname\"\;\"$FILE\"\;\"$filenamedatetime\"\;\"$exifCreateD\"\;\"$exifDatTimOrgD\"\;\"$exifModDat\"\;\"$OldesDateFile\"\;\"$Oldest2ndDate\" >>$myFileCSV
	json=""
done <$ScriptName.FileList.lst
