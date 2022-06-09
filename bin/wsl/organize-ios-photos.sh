#!/bin/bash

# Alle HEVC-Bilder nach JPEG umwandeln, Originale löschen
find . -name "*.HEIC" -print0 | while read -d $'\0' file
do
    #Filename with path 	"$file"
	#Extension 				"${file%.*}"
	#File without extension $(basename "$file")
	
	heif-convert "$file" "${file%.*}.JPG"
	rm "$file"
	
done

# Alle JPEG-Bilder auf den Zeitstempel der Aufnahme umbenennen
find . -name "*.JPG" -print0 | while read -d $'\0' file
do 
	
	exiftool -d %Y-%m-%d_%H.%M.%S%%-c.jpg "-filename<CreateDate" "$file"
	
done

# Alle Filme auf den Zeitstempel der Erzeugung umbenennen
find . -name "*.MOV" -print0 | while read -d $'\0' file
do 
	
	exiftool -d %Y-%m-%d_%H.%M.%S.mov "-filename<CreationDate" -ext MOV "$file"
	
done
