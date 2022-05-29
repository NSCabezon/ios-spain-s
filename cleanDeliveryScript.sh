#!/bin/bash
filename='extras/cleanDeliveryFiles'
while read line; do
# reading each line
	echo "Deleting $line"
	find . -name "$line" -type f -delete
done < $filename

folders='extras/cleanDeliveryFolders'
while read line; do
# reading each line
	echo "Deleting $line"
	find . -name $line -type d -exec rm -rf {} +
done < $folders