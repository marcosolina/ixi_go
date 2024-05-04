#!/bin/bash

URL="https://www.sourcemm.net/downloads.php?branch=dev"

HTML=$(curl -s "$URL")
TAG=$(echo "$HTML" | grep -o "<a.*class='quick-download download-link'.*href='[^']*linux.tar.gz'")
FILE_URL=$(echo "$TAG" | sed -n "s/.*href='\([^']*\)'.*/\1/p")
echo "$HREF"

# Download the FILE_URL
wget "$FILE_URL"

