#!/bin/bash

STEP_NAME=${1:-resources}
MODULES_DIR="./modules"

# Check if the modules directory exists
if [ ! -d "$MODULES_DIR" ]; then
    echo "Error: Modules directory not found at $MODULES_DIR"
    exit 1
fi

# Loop through each directory in the modules folder
for module_dir in "$MODULES_DIR"/*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Processing module: $module_name"

        if [ "$STEP_NAME" = "iam" ]; then
            echo "    Removing everything except for iam.tf, variables.tf"
            for file in "$module_dir"/*; do
                if [[ "$(basename "$file")" != "iam.tf" && "$(basename "$file")" != "variables.tf" ]]; then
                    rm -rf $file
                fi
            done

            output_file="$module_dir/outputs.tf"
            if [ -f "$output_file" ]; then
                echo "    Setting outputs.tf values to null to prevent 'Error: Unsupported attribute'"
                sed -i -E 's/value = .*/value = null/' "$output_file"
            fi
            echo "    Done"
        elif [ "$STEP_NAME" = "resources" ]; then
            rm -rf "$module_dir/iam.tf"
            echo "    Removed iam.tf"
        fi
    fi
done

echo "Processing complete!"