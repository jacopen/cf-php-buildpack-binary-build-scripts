#!/bin/bash
#
# Upload files in the output directory to DropBox
#
# Date: 7-8-2014
# Author: Daniel Mikusa <dmikusa@gopivotal.com>
#
# Usage:
#   ./upload.sh
#

function versionToFunName {
    case $1 in
        Ubuntu-10.04)
            VERSION_NAME=lucid
            ;;
        Ubuntu-12.04)
            VERSION_NAME=precise
            ;;
        Ubuntu-14.04)
            VERSION_NAME=trusty
            ;;
        *)
            echo "Unable to find version name for [$1] :("
            exit -1
            ;;
    esac
}

# Get ROOT Directory
if [[ "$0" == /dev/* ]]; then
    ROOT=$(pwd)
elif [[ "$0" == *bash* ]]; then
    ROOT=$(pwd)
elif [[ "$0" == /* ]]; then
    ROOT=$(dirname "$(dirname "$0")")
else
    ROOT=$(dirname $(dirname "$(pwd)/${0#./}"))
fi
echo "Local working directory [$ROOT]"

UPLOAD_DIR="$ROOT/output"
echo "Uploading files from [$UPLOAD_DIR]"

for FOLDER in "$UPLOAD_DIR"/*; do
    if [ -d "$FOLDER" ]; then
        OS_AND_VERSION=$(basename "$FOLDER")
        versionToFunName "$OS_AND_VERSION"
        echo "Uploading [$OS_AND_VERSION]..."
        for SUBFOLDER in "$FOLDER"/*; do
            COMPONENT=$(basename "$SUBFOLDER")
            echo " Component [$COMPONENT]..."
            for FILE in "$SUBFOLDER"/*; do
                COMPONENT_NAME=$(echo "$COMPONENT" | cut -d '-' -f 1)
                COMPONENT_VERSION=$(echo "$COMPONENT"  |cut -d '-' -f 2)
                FILE_BASE=$(basename "$FILE")
                TO_PATH="Public/binaries/$VERSION_NAME/$COMPONENT_NAME/$COMPONENT_VERSION/$FILE_BASE"
                "$ROOT/dropbox/dropbox_uploader.sh" upload "$FILE" "$TO_PATH"
            done
            echo
        done
        echo
    fi
done
