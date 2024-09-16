#!/bin/bash

STEP_NAME=${1:-resources}
MODULES_DIR="./modules"

# Function to remove existing default symlink or directory
remove_existing_default() {
    if [ -L "$module_dir/default" ] || [ -d "$module_dir/default" ]; then
        rm -rf "$module_dir/default"
    fi
}

# Function to create variables.tf symlink
create_variables_symlink() {
    if [ -f "$module_dir/variables.tf" ]; then
        echo "    Creating variables.tf symlink in default"
        ln -sf "../variables.tf" "$module_dir/default/variables.tf"
    fi
}

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
        if [ -d "$module_dir/$STEP_NAME" ]; then
            echo "  Creating symlink: default -> $STEP_NAME"
            
            remove_existing_default
            
            # Create new symlink
            ln -s "$STEP_NAME" "$module_dir/default"
            
            create_variables_symlink
        else
            echo "  Step '$STEP_NAME' not found in $module_name. Creating default directory."

            remove_existing_default

            # Create default directory and empty main.tf
            mkdir -p "$module_dir/default"
            touch "$module_dir/default/main.tf"
            echo "    Created empty main.tf in default directory"
            
            create_variables_symlink
        fi
    fi
done

echo "Processing complete!"