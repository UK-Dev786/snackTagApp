# Alternative approach using a temporary directory

# 1. Create a temporary directory
mkdir ../temp_repo

# 2. Copy all your files EXCEPT the large ones to the temp directory
# Don't copy .git directory, build directory, or .dart_tool directory
rsync -av --exclude='.git/' --exclude='build/' --exclude='.dart_tool/' ./ ../temp_repo/

# 3. Copy the updated .gitignore to the temp directory
cp .gitignore ../temp_repo/

# 4. Initialize a new Git repository in the temp directory
cd ../temp_repo
git init

# 5. Add all files
git add .

# 6. Commit
git commit -m "Clean repository without large files"

# 7. Add your GitHub remote
git remote add origin https://github.com/WaseemMirzaa/snackTagApp.git

# 8. Push to a new branch
git push -f origin master:clean-waseem-remote  # This creates a new branch

# 9. On GitHub, create a PR from clean-waseem-remote to your main branch
# 10. After merging, you can delete the clean-waseem-remote branch