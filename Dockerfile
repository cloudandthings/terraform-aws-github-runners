# Use latest Ubuntu-based devcontainer by default
ARG TAG="latest"
FROM mcr.microsoft.com/vscode/devcontainers/base:${TAG}

# Install additional OS packages.
RUN apt update -y && export DEBIAN_FRONTEND=noninteractive \
    && apt install -y --no-install-recommends gpg wget curl

# Install mise for Ubuntu
RUN install -dm 755 /etc/apt/keyrings \
    && wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list \
    && apt update -y && apt install -y mise

# 1] Activate mise by default in bash
# 2] Add mise shims to path
RUN echo 'eval "$(/usr/bin/mise activate bash)"' >> /etc/bash.bashrc \
    && echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >> /etc/bash.bashrc

# AVD-DS-0002 (HIGH): Specify at least 1 USER command in Dockerfile with non-root user as argument
USER vscode
