#!/usr/bin/env bash
# create_notes.sh
# Purpose: create 3 numbered note files for a given project name, with input validation.

read -r -p "Enter project name: " project_name

# Validation: reject empty input or anything containing a slash (path traversal risk)
if [[ -z "$project_name" || "$project_name" == *"/"* ]]; then
    echo "Error: project name must not be empty or contain '/' characters." >&2
    exit 1
fi

target_dir=~/wadf-labs/week3/generated-notes/"$project_name"
mkdir -p "$target_dir"

for i in 1 2 3; do
    echo "Notes for project: $project_name" > "$target_dir/note_${i}.txt"
    echo "Created: $target_dir/note_${i}.txt"
done

echo "Done. All notes created in $target_dir"
