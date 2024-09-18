#!/bin/bash

# Default values for optional parameters
CAPTION=""
PREFIX=""
PARSE_MODE="Markdown"

# Function to show usage
usage() {
    echo "Usage: $0 -file <file> -token <token> -chatid <chat_id> [-caption <caption>] [-prefix <prefix>] [-parse_mode <Markdown|MarkdownV2>]"
    exit 1
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -file) FILE="$2"; shift ;;
        -token) TOKEN="$2"; shift ;;
        -chatid) CHAT_ID="$2"; shift ;;
        -caption) CAPTION="$2"; shift ;;
        -prefix) PREFIX="$2"; shift ;;
        -parse_mode) PARSE_MODE="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Check for mandatory parameters
if [ -z "$FILE" ] || [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
    usage
fi

# Ensure CHAT_ID starts with '-'
if [[ ! "$CHAT_ID" =~ ^- ]]; then
    CHAT_ID="-$CHAT_ID"
fi

# Default the prefix to the file name if not provided
PREFIX="${PREFIX:-${FILE}}"

# Compress and split the file into 45MB parts with the specified prefix
zip -s 48m "${PREFIX}.zip" "$FILE"

# Upload the main ZIP file first
if [ -r "${PREFIX}.zip" ]; then
    curl -F document=@"${PREFIX}.zip" \
         -F caption="$CAPTION" \
         -F parse_mode="$PARSE_MODE" \
         "https://api.telegram.org/bot$TOKEN/sendDocument?chat_id=$CHAT_ID"
else
    echo "Error: Cannot read file ${PREFIX}.zip"
    exit 1
fi

# Upload the split parts (.z01, .z02, etc.) after
for file in "${PREFIX}.z"[0-9][0-9]; do
    if [ -r "$file" ]; then
        curl -F document=@"$file" \
             "https://api.telegram.org/bot$TOKEN/sendDocument?chat_id=$CHAT_ID"
    else
        echo "Error: Cannot read file $file"
        exit 1
    fi
done
