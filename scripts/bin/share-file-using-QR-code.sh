#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR=$SCRIPT_DIR/utils

selected=$($UTILS_DIR/find_file.sh)
echo "## sharing: $selected"
[ -z "$selected" ] && exit 1

filename=$(basename "$selected")

# 172800 means 48hrs but it doesn't work. It seems just 1hr, maybe?
tmp_response=$(mktemp)
{
    curl -s \
        -F "file=@$selected;filename=$filename" \
        -F "expire=172800" \
        https://tmpfiles.org/api/v1/upload > "$tmp_response"
} &
curl_pid=$!
$UTILS_DIR/show_spinner.sh $curl_pid
wait $curl_pid
response=$(cat "$tmp_response")

url=$(echo "$response" | jq -r '.data.url')

if [ "$url" != "null" ] && [ -n "$url" ]; then
    dl_url=$(echo "$url" | sed 's/tmpfiles.org\//tmpfiles.org\/dl\//')
    echo "## download url: $dl_url"
    curl -s "https://qrenco.de/$dl_url"
else
    echo "업로드 실패: $response"
fi

rm -f "$tmp_response"
