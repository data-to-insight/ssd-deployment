#!/bin/bash
# chmod +x update_la_deployment_extracts.sh

# Array of LA names
names=("east-sussex" "knowsley" "bradford")

# Base URLs and directories
source_repo_url="https://github.com/data-to-insight/ssd-data-model"
destination_base_dir="/workspaces/ssd-deployment"
source_base_dir="/workspaces/ssd-data-model/la_deployment"

# Iterate over each LA in the list
for name in "${names[@]}"; do
  echo "Copying $name..."

  # Check if source directory exists
  if [ -d "$source_base_dir/$name" ]; then
    # Copy the entire folder from the source to the destination
    cp -r "$source_base_dir/$name" "$destination_base_dir/"

    # Navigate to the destination repository
    cd "$destination_base_dir"

    # Add the copied folder to Git
    git add "$name"
    git commit -m "Add $name deployment folder"

  else
    echo "Source directory $source_base_dir/$name does not exist. Skipping."
  fi
done

# Push all changes to the remote repository
git push origin main

echo "All folders copied and committed."