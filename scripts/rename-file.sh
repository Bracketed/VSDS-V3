#!/bin/bash

target_dir="[path]"

for dir in "$target_dir"/*; do
    if [ -d "$dir" ]; then
        current_name=$(basename "$dir")
        new_name="new_${current_name}"
        mv "$dir" "$target_dir/$new_name"        
        echo "Renamed directory: $current_name to $new_name"
    fi
done