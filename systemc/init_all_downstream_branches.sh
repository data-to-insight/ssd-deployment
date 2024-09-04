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

# Iterate over each LA and system type
for la in "${!la_system_map[@]}"; do
  system=${la_system_map[$la]}

  # Create branch for each LA and system type if it doesn't already exist
  branch_name="${system}-${la}-branch"
  
  if ! git rev-parse --verify $branch_name > /dev/null 2>&1; then
    git checkout -b $branch_name
    
    # Ensure the directory is created and add at least a placeholder file
    mkdir -p $system/$la/
    echo "Placeholder for $system-$la" > $system/$la/README.md

    # Add the new files and directories to the branch
    git add $system/$la/
    git commit -m "Initial setup for $system-$la"
    git push origin $branch_name
  fi
done

# Return to the main branch
git checkout main

# Ensure everything is staged and committed (including the script itself)
git add systemc/init_all_downstream_branches.sh
git commit -m "Ensure all changes are committed, including init script."
git push origin main
