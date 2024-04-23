#!/bin/bash

source_path="./source/src"
target_path="./Obfuscator"
ls

for dir in "$source_path"/*/; do
    current_dir=${dir%/}

    cp -r "$current_dir/"* "$target_path/"

    lua_files=$(find "$target_path" -name "*.lua")

    ls ./Obfuscator

    for lua_file in $lua_files; do
        file_name=$(basename "$lua_file")

        dotnet ./Obfuscator/YolusCLI.dll $lua_file
        echo ":: YOLUS :: ${file_name} was Obfuscated successfully."

        obfuscated_file="${target_path}/${file_name%.*}-obfuscated.lua"

        cp "$obfuscated_file" "$current_dir/"

        rm "$lua_file"
        rm "$obfuscated_file"
    done
done
