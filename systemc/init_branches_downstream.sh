#!/bin/bash

# List of organizations
orgs=("org1" "org2" "org3" "org4")

# System types (e.g., systemc, mosaic)
systems=("systemc" "mosaic")

# Iterate over each organization and system type
for org in "${orgs[@]}"; do
  for system in "${systems[@]}"; do
    # Create a branch for each organization if it doesn't already exist
    if ! git rev-parse --verify $system-$org-branch > /dev/null 2>&1; then
      git checkout -b $system-$org-branch
      mkdir -p $system/$org/
      git add $system/$org/
      git commit -m "Initial setup for $system-$org"
      git push origin $system-$org-branch
    fi
  done
done

# Return to the main branch
git checkout main
