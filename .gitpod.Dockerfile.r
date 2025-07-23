FROM gitpod/workspace-base

# Multi-stage build for certificate handling
FROM alpine:latest AS roche-certs

WORKDIR /certs

ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Root%20CA.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%201.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%202.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%203.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%204.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%205.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%206.crt .

FROM gitpod/workspace-base AS final

USER root

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Copy certificates from the previous stage
COPY --from=roche-certs /certs /usr/local/share/ca-certificates

# Update ca-certificates
RUN update-ca-certificates

# Set ca-certificates.crt as default cert store
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# --------------------------------------------------------------------------------
# SECTION 1: SYSTEM DEPENDENCIES & NVIDIA SUPPORT
# --------------------------------------------------------------------------------
# Install system dependencies including those needed for PyTorch/CUDA
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    git \
    cmake \
    libxml2-dev \
    libxmlsec1-dev \
    lzma

# Install NVIDIA drivers and CUDA support (non-interactive)
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#     nvidia-driver-550 \
#     nvidia-cuda-toolkit

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xauth && \
    echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------------------
# SECTION 2: MISE INSTALLATION
# --------------------------------------------------------------------------------
USER gitpod

RUN /bin/bash -c "$(curl -fsSL https://mise.run)"

ENV PATH="/local/bin:${PATH}"

RUN mise use -g fzf@latest
RUN mise use -g lazygit@latest
RUN mise use -g uv@latest
RUN mise use -g python@3.12
RUN mise use -g go@1.24.5

RUN echo 'eval "$(/home/gitpod/.local/bin/mise activate bash)"' >> /home/gitpod/.bashrc

USER root

# --------------------------------------------------------------------------------
# SECTION 4: FINAL PERMISSIONS AND USER SETUP
# --------------------------------------------------------------------------------
# Set final ownership for the gitpod user's home directory
RUN chown -R gitpod:gitpod /home/gitpod

# Switch to the final user
USER gitpod
