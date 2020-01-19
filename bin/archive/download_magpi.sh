#!/bin/bash
# Name : download_magpi.sh
# Autor: Carsten Söhrens


for value in {1..57} ; do

	while [[ ${#value} -lt 2 ]] ; do
		value="0${value}"
	done

	echo Downloading issue MagPi$value.pdf
	wget https://raspberrypi.org/magpi-issues/MagPi$value.pdf

done

echo All done



