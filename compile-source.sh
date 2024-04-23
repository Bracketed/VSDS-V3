#!/bin/bash

# Get the list of folders in ./source/src
source_folders=(./source/src/*)

# Loop through each folder in the ./source/src directory
for folder in "${source_folders[@]}"; do
    # Get the name of the folder without the full path
    folder_name=$(basename "$folder")

    # Copy all files from the current folder to the ./Obfuscator directory
    cp -r "$folder/"* "./Obfuscator/"

    # Loop through each .lua file in the ./Obfuscator directory
    for lua_file in ./Obfuscator/*.lua; do
        # Check if it's a file
        if [ -f "$lua_file" ]; then
            # Run dotnet YolusCLI.dll on the .lua file to produce the obfuscated version
            obfuscated_file="${lua_file%.lua}-obfuscated.lua"
            dotnet YolusCLI.dll "$lua_file"

            # Overwrite the original file in the source folder with the obfuscated content
            obfuscated_content=$(cat "$obfuscated_file")
            original_file="$folder/${lua_file##*/}"
            echo "$obfuscated_content" >"$original_file"

            # Delete the obfuscated file
            rm "$obfuscated_file"
        fi
    done
done
