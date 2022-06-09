#!/bin/bash
# Name : link.sh
# Autor: Carsten Söhrens

PROJEKTRON_VERSION=$(cat /opt/projektron/bcs/server/VERSION.TXT)
MAINVERSION=$(expr substr $PROJEKTRON_VERSION 1 4)
SUBVERSION=$PROJEKTRON_VERSION
FILE=$(ls  .* | grep $MAINVERSION | sort | tail -1)

# Variables defined in docker run
echo "Variables"
echo "BCS-VERSION : $PROJEKTRON_VERSION"

# Using the first 4 chars of the minor version, to get major version (e.g. 21.3.24 -> 21.3)
echo "Mainversion : $MAINVERSION"
echo "Subversion  : $SUBVERSION"
echo "Latest File : $FILE"

# Linking to the latest
ln -sf $FILE projektron-bcs-latest.zip
