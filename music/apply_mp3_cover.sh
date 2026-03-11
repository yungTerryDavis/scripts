#!/bin/sh

# Get dir
if [[ -z "$1" ]]; then
	echo "Error. $0 should be applied to a directory"
	exit 1
fi

dir="$1"

if [[ ! -d "$dir" ]]; then
	echo "Error. '$dir' doesn't exist or not a directory"
	exit 1
fi

# Get cover
cover=$(find "$dir" -maxdepth 1 -type f -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" | head -n 1)

if [[ -z "$cover" ]]; then
	echo "Error. '$dir' doesn't contain JPG or PNG file"
	exit 1
else
	echo "Found cover: $cover"
fi

# Get array of mp3 files
mapfile -t tracks < <(find "$dir" -maxdepth 1 -type f -iname "*.mp3" -o -iname "*.flac")

if [[ ${#tracks[@]} -eq 0 ]]; then
	echo "Error. No MP3/FLAC files found"
	exit 1
fi

# Apply cover

for file in "${tracks[@]}"; do
	if [[ "$file" == *.mp3 ]]; then
		mid3v2 -p "$cover" "$file"
	else
		metaflac --import-picture-from="$cover" "$file"
	fi
	echo "Applied cover to '$file'"
done

echo "All mp3/flac files in '$dir' processed!"
