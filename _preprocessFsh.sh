#!/bin/bash

versions=("4.0.1" "5.0.0")

for version in "${versions[@]}"; do
    if [ "$version" = "4.0.1" ]; then
        context_version="R4"
        build_dir="igs/r4"
    elif [ "$version" = "5.0.0" ]; then
        context_version="R5"
        build_dir="igs/r5"
    fi

    # Check if version-specific directory exists
    if [ ! -d "$build_dir/input/fsh" ]; then
        echo "Error: Directory $build_dir/input/fsh does not exist"
        exit 1
    fi

    # Process sushi-config
    echo "Processing sushi-config.yaml.liquid for version $version"
    # Create temporary config in base directory
    npx --yes liquidjs -t @"IG-base/sushi-config.yaml.liquid" --context @"context-${context_version}.json" > "sushi-config.yaml"
    # Copy to build directory
    cp sushi-config.yaml "$build_dir/sushi-config.yaml"
    # Remove from base directory
    rm sushi-config.yaml

    # Process all liquid FSH files
    find IG-base/input/fsh -type f -name "*.liquid.fsh" | while read file; do
        if [ -f "$file" ]; then
            relative_path=${file#IG-base/input/fsh/}
            dir_path=$(dirname "$relative_path")
            base_name=$(basename "$file")
            
            echo "Processing file $file for $version"
            
            # Create directory structure if it doesn't exist
            mkdir -p "$build_dir/input/fsh/$dir_path"
            echo "Created directory: $build_dir/input/fsh/$dir_path"
            
            output_file="$build_dir/input/fsh/$dir_path/${base_name%.liquid.fsh}.fsh"
            echo "Will write to: $output_file"
            
            echo "Processed $base_name for $version..."
            
            # Process liquid template and inline version tags
            content=$(npx --yes liquidjs -t @"$file" --context @"context-${context_version}.json")
            echo "$content" > "$output_file"
            
            # Check if file was created
            if [ -f "$output_file" ]; then
                echo "Successfully created $output_file"
                ls -l "$output_file"
            else
                echo "Debug: Failed to create $output_file"
            fi
        fi
    done

    # Remove empty files (where no version matched)
    find "$build_dir/input/fsh" -type f -name "*.fsh" -size 0 -delete

    echo "FSH files processed and moved to $build_dir/input/fsh/ for $version"

    # Copy all non-liquid files from IG-base directory
    echo "Copying non-liquid files from IG-base directory to $build_dir..."
    cd IG-base

    find input -type f ! -name "*.liquid.*" | while read file; do
        relative_path=${file#input/}  # Strip only the first "input/" prefix
        mkdir -p "../$build_dir/input/$(dirname "$relative_path")"
        cp "$file" "../$build_dir/input/$relative_path"
    done

    cd ..
done