for i in *.jpeg
do
#	exiftool  -DateTimeOriginal "$i"
	exiftool -overwrite_original -if '(not $DateTimeOriginal) or ($DateTimeOriginal lt "2001:01:02 00:00:00") or ($DateTimeOriginal gt $CreateDate)' '-DateTimeOriginal<${filename;s/.*([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2}-[0-9]{2}).*/$1 $2/}' "$i"  
#	exiftool -overwrite_original -if '(not $DateTimeOriginal) or ($DateTimeOriginal lt "2001:01:02 00:00:00") or ($DateTimeOriginal gt $CreateDate)' '-DateTimeOriginal<${filename;s/.*([0-9]{4}-[0-9]{2}-[0-9]{2})--([0-9]{2}-[0-9]{2}-[0-9]{2}).*/$1 $2/}' "$i"  
#	exiftool "-FileCreateDate<${DateTimeOriginal}" "-FileModifyDate<${DateTimeOriginal}" "$i"
done
