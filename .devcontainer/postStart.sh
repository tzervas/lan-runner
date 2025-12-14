#!/usr/bin/env bash
set -euo pipefail

echo "postStart: Checking for host GPG and git config mounts..."

if [ -d "/home/vscode/.gnupg" ]; then
  echo "Found host GPG directory: /home/vscode/.gnupg"
else
  echo "No host GPG directory found at /home/vscode/.gnupg; the container will use its own gpg keyring."
fi

if [ -f "/home/vscode/.gitconfig" ]; then
  echo "Found host git config: /home/vscode/.gitconfig"
else
  echo "No host .gitconfig found. Configure git user.name and user.email in the container or mount your host .gitconfig"
fi

# Find default secret key id if present
sigkey=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | awk '/^sec/{print $2}' | cut -d'/' -f2 | head -n1 || true)
if [[ -n "$sigkey" ]]; then
  echo "Configuring git global signing key: $sigkey"
  git config --global user.signingkey "$sigkey"
  git config --global commit.gpgsign true
  git config --global gpg.program gpg
else
  echo "No GPG secret key found — commit signing will be disabled in container until you mount/restore keys."
fi

echo "postStart: done."
