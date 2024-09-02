#!/bin/bash
# chmod +x test.sh

#!/bin/bash
# chmod +x test.sh

# Check if already in the ssd-deployment directory
if [ ! -d ".git" ]; then
  echo "Error: Not a git repository. Make sure you are in the 'ssd-deployment' directory."
  exit 1
fi

# Ensure the remote for ssd-data-model exists
if ! git remote get-url ssd-data-model > /dev/null 2>&1; then
  git remote add ssd-data-model https://github.com/data-to-insight/ssd-data-model.git
fi

# Fetch the latest changes from the source repository (check for errors)
if ! git fetch ssd-data-model; then
  echo "Error: Failed to fetch from ssd-data-model. Check your permissions."
  exit 1
fi

# Enable sparse checkout and pull the specific folder from the source repository
git config core.sparseCheckout true
echo "cms_ssd_extract_sql/systemc/live/" > .git/info/sparse-checkout

if ! git checkout ssd-data-model/main -- cms_ssd_extract_sql/systemc/live/; then
  echo "Error: Failed to checkout the specific folder. Invalid reference or permissions issue."
  exit 1
fi

# Create the systemc directory in the downstream repository
mkdir -p systemc/

# Move the folder's contents to the systemc directory
mv cms_ssd_extract_sql/systemc/live/* systemc/

# Remove the empty directory structure after the move
rm -rf cms_ssd_extract_sql/

# Stage, commit, and push the changes to the downstream repository
git add .
git commit -m "Add live SQL files from ssd-data-model repository"
git push origin main
