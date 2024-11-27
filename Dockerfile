# Docker image for executing Terraform static code analysis tools and pre-commit hooks
# This may be run as a devcontainer in VSCode or as a standalone container for tests
# Inspired by https://github.com/alastairhm/docker-terraform-check

ARG TAG=latest

FROM ubuntu:${TAG} as this

ARG USER=user

ARG TFSEC_VER=v1.28.1
ARG TFLINT_VER=v0.43.0
ARG TFDOCS_VER=v0.19.0

# Install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends \
    bash ca-certificates wget git unzip tar python3 python3-venv && \
    update-ca-certificates -f

# Install Terraform static code analysis tools.
COPY .tflint.hcl .
COPY .tfsec-config.yml .
COPY .tfdocs-config.yml .
RUN wget https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VER}/tfsec-linux-amd64 -O /usr/bin/tfsec && chmod +x /usr/bin/tfsec && \
    wget https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VER}/tflint_linux_amd64.zip && unzip tflint_linux_amd64.zip && mv tflint /usr/bin && rm tflint_linux_amd64.zip && \
    tflint --config .tflint.hcl --init && \
    wget https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VER}/terraform-docs-${TFDOCS_VER}-linux-amd64.tar.gz -O terraform-docs.tar.gz && \
    tar -xzf terraform-docs.tar.gz && chmod +x terraform-docs && mv terraform-docs /usr/bin && rm terraform-docs.tar.gz

# For dev container in VSCode, create a non-root user.
RUN useradd -ms /bin/bash ${USER}
USER ${USER}
