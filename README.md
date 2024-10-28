
# Igniter Scripts Collection

A collection of igniter scripts designed to provide setup steps for various environments, including server configurations and Git repository initialization. Each script serves as a foundational tool, igniting core configurations needed to get systems up and running.

## Overview

These scripts automate initial setup tasks for both development and production environments. Tasks can include user creation, security configurations, software initialization, and repository setup.

## Usage
### Using Scripts from Source
   ```bash
   ## Clone the repository
   git clone https://github.com/ozibozi/igniters.git
   ## Navigate to the scripts directory
   cd scripts
   ## Make scripts executable
   chmod +x *.sh
   ## Run scripts as needed
   ./script-name.sh
   ```
## Using Scripts via Raw GitHub Files
You can run the scripts directly from the raw GitHub URL using `curl` or `wget`:
### Using `curl`
   ```bash
   curl -s https://raw.githubusercontent.com/ozibozi/igniters/main/scripts/ubuntu-igniter.sh
   ```
### Using `wget`
   ```bash
   wget -qO- https://raw.githubusercontent.com/<username>/igniters/main/ubuntu-igniter.sh
   ```
  

## Contributing

Feel free to contribute additional igniter scripts or suggest improvements to existing ones. This collection aims to provide foundational, reusable scripts for common setup tasks across various environments.
