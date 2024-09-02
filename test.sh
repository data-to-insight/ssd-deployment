#!/bin/bash
# chmod +x test.sh

# Clone the downstream repository
git clone https://github.com/data-to-insight/ssd-deployment.git
cd ssd-deployment

# Add the source repository as a remote
git remote add ssd-data-model https://github.com/data-to-insight/ssd-data-model.git

# Fetch the latest changes from the source repository
git fetch ssd-data-model

# Enable sparse checkout and pull the specific folder from the source repository
git config core.sparseCheckout true
echo "cms_ssd_extract_sql/systemc/live/" >> .git/info/sparse-checkout
git checkout ssd-data-model/main -- cms_ssd_extract_sql/systemc/live/

# Move the folder's contents to the root of the downstream repository
mv cms_ssd_extract_sql/systemc/live/* .
rm -rf cms_ssd_extract_sql/

# Stage, commit, and push the changes to the downstream repository
git add .
git commit -m "Add live SQL files from ssd-data-model repository"
git push origin main
