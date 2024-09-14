# !/bin/bash


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
            
            # Remove existing symlink if it exists
            if [ -L "$module_dir/default" ]; then
                rm "$module_dir/default"
            fi
            
            # Create new symlink
            ln -s "$STEP_NAME" "$module_dir/default"
            
            # Create variables.tf symlink in the default directory
            if [ -f "$module_dir/variables.tf" ]; then
                echo "    Creating variables.tf symlink in default"
                ln -sf "../variables.tf" "$module_dir/default/variables.tf"
            fi
        else
            echo "  Warning: Step '$STEP_NAME' not found in $module_name"
        fi
    fi
done

echo "Symlinking complete!"