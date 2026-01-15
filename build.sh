#!/bin/bash

# Define options
type="fpm"
versions=("8.0" "8.1" "8.4")

echo "Select PHP version:"
select version in "${versions[@]}"; do
    if [[ -n "$version" ]]; then
        break
    else
        echo "Invalid selection."
    fi
done

# Ask for --no-cache
echo
read -p "Do you want to build with --no-cache? (y/N): " nocache
if [[ "$nocache" =~ ^[Yy]$ ]]; then
    nocache_flag="--no-cache"
else
    nocache_flag=""
fi

# Build command
echo
docker build $nocache_flag -t "ramainvicta/php:${version}-${type}" -f "${type}/v${version}/Dockerfile" .
