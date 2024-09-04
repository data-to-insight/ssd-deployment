#!/bin/bash
# chmod +x ./systemc/init_all_downstream_branches.sh

# LAs to system types
declare -A la_system_map

# Populate with LA:systemtype pairs
la_system_map=(
    ["la1"]="systemc"
    ["la2"]="systemc"
    ["la3"]="mosaic"
    ["la4"]="mosaic"
)

# Ensure sparse checkout is correctly set
git config core.sparseCheckout true

# Add relevant paths (including the script) to sparse-checkout
echo "systemc/init_all_downstream_branches.sh" > .git/info/sparse-checkout
echo "systemc/" >> .git/info/sparse-checkout
echo "mosaic/" >> .git/info/sparse-checkout

# Reapply sparse checkout to update the working directory
git sparse-checkout reapply

# Fetch and move the necessary files for each LA
for la in "${!la_system_map[@]}"; do
  system=${la_system_map[$la]}

  # Create branch for each LA and system type if it doesn't already exist
  branch_name="${system}-${la}-branch"
  
  if ! git rev-parse --verify $branch_name > /dev/null 2>&1; then
    git checkout -b $branch_name

    # Fetch the specific folder from the upstream repository
    if ! git checkout ssd-data-model/main -- deployment_extracts/$system/live/; then
      echo "Error: Failed to checkout the $system folder for $la."
      exit 1
    fi
    
    # Ensure the directory for the LA is created
    mkdir -p $system/$la/

    # Move the fetched files into the LA's subdirectory
    mv deployment_extracts/$system/live/* $system/$la/

    # Remove the empty fetched directory
    rm -rf deployment_extracts/$system/

    # Add and commit the new files
    git add $system/$la/
    git commit -m "Setup for $system-$la"
    git push origin $branch_name
  fi
done

# Return to the main branch
git checkout main

# Ensure the script itself is committed to the main branch
git add systemc/init_all_downstream_branches.sh
git commit -m "Ensure all changes are committed, including init script."
git push origin main
