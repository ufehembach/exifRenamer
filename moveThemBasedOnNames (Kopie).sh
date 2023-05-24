#!/bin/bash

# Set the Internal Field Separator (IFS) to newline character
# This ensures that the for loop processes each file separately, even if the filename contains spaces
IFS=$'\n'

# Gehe durch alle Dateien im aktuellen Verzeichnis mit Namen nach dem Muster "yyyy-mm-dd-*"
# exclude "@eaDir" folder
for myFolder in $(find . -name "????-??-??" ! -path "*/@eaDir/*"); do
    # Extrahiere das Datum aus dem Dateinamen
    echo $myFolder
    date=$(echo "$myFolder" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    if [ -n "$date" ]; then
        # Erstelle das Verzeichnis für das Datum, falls es noch nicht existiert
        mkdir -p "$(echo $date | tr '-' '/')"
        # Verschiebe die Datei in das entsprechende Verzeichnis
        #mv "$myFolder" "$(echo $date | tr '-' '/')"
        echo mv "$myFolder" "$(echo $date | tr '-' '/')"
        mv "$myFolder" "$(echo $date | tr '-' '/')"
     #   echo "Datei \"$myFolder\" wurde in das Verzeichnis $(echo $date | tr '-' '/') verschoben"
    fi
done

# Set IFS back to its original value
unset IFS

