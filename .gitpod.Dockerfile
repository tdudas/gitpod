FROM public.ecr.aws/docker/library/rockylinux:9

# Multi-stage build for certificate handling
FROM alpine:latest AS r-certs

WORKDIR /certs

ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Root%20CA.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%201.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%202.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%203.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%204.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%205.crt .
ADD https://certinfo.roche.com/rootcerts/Roche%20G3%20Issuing%20CA%206.crt .

FROM public.ecr.aws/docker/library/rockylinux:9 AS final

USER root

# DNF packages
RUN dnf install -y epel-release

RUN dnf -y update && \
    dnf install -y --allowerasing \
      epel-release \
      unzip git wget \
      curl tmux procps-ng \
      bind-utils telnet \
      tar gzip findutils shadow-utils \
      which hostname \
      dnf-plugins-core \
      bash-completion openldap-clients \
      sudo vim net-tools \
      && dnf clean all

## VNC PACKAGES
RUN dnf -y install \
    xfce4-panel xfce4-session xfce4-settings xfconf xfce4-terminal \
    xorg-x11-server-Xvfb x11vnc tigervnc-server tigervnc \
    chromium novnc procps \
    gnupg python3 \
    fontconfig libXcomposite libXcursor libXdamage libXrandr libXScrnSaver alsa-lib atk at-spi2-atk at-spi2-core cups-libs gtk3 libdrm libxshmfence libgbm libXtst nss libxkbcommon \
    && dnf -y groupinstall "Xfce" \
    && dnf clean all
##

ENV TZ=UTC

COPY --from=r-certs /certs /etc/pki/ca-trust/source/anchors

RUN update-ca-trust extract

ENV SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt \
    REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt


RUN echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# --------------------------------------------------------------------------------
# GITPOD USER
# --------------------------------------------------------------------------------
RUN groupadd -g 33333 gitpod && \
    useradd -u 33333 -g 33333 -m -s /bin/bash gitpod

# gitpod user & sudo
RUN mkdir -p /etc/sudoers.d && \
    echo "gitpod ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gitpod && \
    chmod 0440 /etc/sudoers.d/gitpod

# --------------------------------------------------------------------------------
# MISE PACKAGE INSTALLATION
# --------------------------------------------------------------------------------
USER gitpod

RUN /bin/bash -c "$(curl -fsSL https://mise.run)"

ENV PATH="/home/gitpod/.local/bin:${PATH}"

COPY mise_config.toml /home/gitpod/.config/mise/config.toml

RUN mkdir -p /home/gitpod/.config/mise && \
    mise install

RUN echo 'eval "$(/home/gitpod/.local/bin/mise activate bash)"' >> /home/gitpod/.bashrc

USER root

RUN chown -R gitpod:gitpod /home/gitpod

# Switch to the final user
USER gitpod
