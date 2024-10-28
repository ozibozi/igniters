#!/bin/bash
set -e  # Exit if any command fails

# --- Handle Ctrl+C ---
trap 'echo "Script canceled by user."; exit 0;' SIGINT


# --- Step 1: Prompt for Username and Repository Name ---
# Default to caller's username and current directory name if no input is given

# Prompt for GitHub username
read -p "Enter GitHub username [default: $USER]: " USERNAME
USERNAME=${USERNAME:-$USER}
echo "Using GitHub username: $USERNAME"

# Prompt for repository name
CURRENT_DIR=$(basename "$PWD")
read -p "Enter repository name [default: $CURRENT_DIR]: " REPO
REPO=${REPO:-$CURRENT_DIR}
echo "Using repository name: $REPO"

# --- Step 2: Initialize Git Repository ---
echo "Initializing a new Git repository..."
sleep 1
git init

# --- Step 3: Set up Branches ---
echo "Creating 'main' branch and checking for 'master' branch..."
sleep 1
git checkout -b main

# Attempt to delete 'master' branch if it exists
if git show-ref --verify --quiet refs/heads/master; then
    echo "Deleting existing 'master' branch..."
    git branch -D master
else
    echo "'Master' branch not found; skipping deletion."
fi

# --- Step 4: Configure Remote and Validate ---
echo "Setting up and validating the remote origin..."
git remote add origin https://github.com/$USERNAME/$REPO.git

# Validate remote URL by checking connectivity
if ! git ls-remote origin &> /dev/null; then
    echo "Error: Unable to access remote repository. Check the URL or network connection."
    git remote remove origin
    exit 1
fi

# --- Step 5: Make Initial Commit and Push ---
echo "Creating an initial commit and pushing to the validated remote..."
touch hello
git add hello
git commit -m "Initial commit of setup script"

# Attempt to push to the remote
if ! git push -u origin main; then
    echo "Push failed; attempting to pull and rebase..."
    git pull origin main --rebase
    git push -u origin main
fi

# --- Step 6: Display Final Remote Configuration ---
echo "Configured remotes:"
git remote -v
