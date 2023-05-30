#!/bin/bash

# Check if two arguments are provided
if [ $# -ne 2 ]; then
  echo "source and target directories are required"
  exit 1
fi

SRC=$1 # Source directory
TGT=$2 # Target directory

# Check if source directory exists
if [ ! -d "$SRC" ]; then
  echo "Invalid source directory: $SRC"
  exit 2
fi

# Check if target directory is local or remote
if [[ $TGT == *:* ]]; then
  remote=true
else
  remote=false
fi

# Timestamped directory for the backup
timestamp=$(date +"%Y-%m-%d-%H:%M:%S")
backup_dir="$TGT/$timestamp"

# backup with rsync
if [ "$remote" = true ]; then
  rsync -avz --delete --link-dest="$TGT/latest" -e ssh "$SRC" "$backup_dir"
else
  rsync -avz --delete --link-dest="$TGT/latest" "$SRC" "$backup_dir"
fi

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully."
else
  echo "Backup failed."
  exit 3
fi

# Update the latest symlink to point to the new backup directory
if [ "$remote" = true ]; then
  ssh "${TGT%:*}" "ln -snf $timestamp $TGT/latest"
else
  ln -snf "$timestamp" "$TGT/latest"
fi
