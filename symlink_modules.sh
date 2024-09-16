#!/bin/bash

# Script does the following
# Creates symlink for iam/ and resources/ -> modules/*/variables.tf
# Creates symlink for modules/*/default/ -> iam/ or resources/ based on STEP_NAME (or creates a default/ with empty main.tf and symlinks variables.tf if STEP_NAME folder doesn't exist)
# If COMBINE_OUTPUTS is true; Combines iam/ouputs.tf and resource/outputs.tf into one. If STEP_NAME is 'iam', the outputs in resources/ values will be replaced with null before adding it to combined_outputs

STEP_NAME=${1:-resources}
COMBINE_OUTPUTS=${2:-false}
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
        
        # Check if variables.tf exists in the module root
        if [ -f "$module_dir/variables.tf" ]; then
            echo "  Found variables.tf in module root"
            
            # Create symlinks for variables.tf in all subdirectories
            for subdir in "$module_dir"/*; do
                if [ -d "$subdir" ] && [ "$(basename "$subdir")" != "default" ]; then
                    echo "    Creating variables.tf symlink in $(basename "$subdir")"
                    ln -sf "../variables.tf" "$subdir/variables.tf"
                fi
            done
        else
            echo "  No variables.tf found in module root"
        fi
        
        # Check if the specified step exists in this module
        if [ -L "$module_dir/default" ] || [ -d "$module_dir/default" ]; then
            rm -rf "$module_dir/default"
        fi

        combined_outputs=""
        for subdir in "$module_dir"/*; do
            if [ -d "$subdir" ]; then
                output_file="$subdir/outputs.tf"
                if [ -f "$output_file" ]; then
                    combined_outputs+="# Outputs from $(basename "$subdir")\n"
    
                    if [ "$subdir_name" != "$STEP_NAME" ]; then
                        # Modify the outputs.tf content for non-matching subdirectories
                        # This will replace all output values with null
                        modified_content=$(sed -E 's/(output[[:space:]]+".+"[[:space:]]*\{[[:space:]]*value[[:space:]]*=)[^}]+/\1 null/' "$output_file")
                        combined_outputs+="$modified_content\n\n"
                    else
                        # Use the original content for the matching subdirectory
                        combined_outputs+="$(cat "$output_file")\n\n"
                    fi
                fi
            fi
        done

        if [ -d "$module_dir/$STEP_NAME" ]; then
            echo "  Creating symlink: default -> $STEP_NAME"
            ln -s "$STEP_NAME" "$module_dir/default"
        else
            echo "  Step '$STEP_NAME' not found in $module_name. Creating default directory."
            mkdir "$module_dir/default"
            touch "$module_dir/default/main.tf"
            echo "    Created empty main.tf in default directory"
            if [ -f "$module_dir/variables.tf" ]; then
                echo "    Creating variables.tf symlink in default"
                ln -sf "../variables.tf" "$module_dir/default/variables.tf"
            fi
        fi
        
        # Write combined_outputs default/outputs.tf (Only do this in CI pipeline since it will also create a outputs.tf in the corresponding symlinked folder as well which we dont need)
        if [ "$COMBINE_OUTPUTS" = true ]; then
            echo -e "$combined_outputs" > "$module_dir/default/outputs.tf"
        fi
    fi
done

echo "Processing complete!"