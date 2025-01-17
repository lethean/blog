#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Fetch lethean.github.io submodule
git submodule update --init --recursive
(cd public && git switch master)

# Build the project.
(cd public && rm -rf *)
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="hugo: rebuild site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

cd ..

git add public
git commit -m "public: rebuild site"
git push
