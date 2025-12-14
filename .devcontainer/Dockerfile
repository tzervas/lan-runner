FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install GPG, git and supporting tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends gnupg2 git curl jq pinentry-curses \
  && rm -rf /var/lib/apt/lists/*

# Dev container will run as vscode user (predefined in base image)
USER vscode
