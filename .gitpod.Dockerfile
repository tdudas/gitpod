FROM public.ecr.aws/docker/library/rockylinux:9

RUN dnf install -y epel-release

RUN dnf -y update && \
    dnf install -y --allowerasing \
      unzip git wget \
      curl vim tmux fzf \
      bind-utils telnet \
      tar gzip findutils shadow-utils \
      which hostname \
      dnf-plugins-core \
      bash-completion \
      sudo \
      && dnf clean all

RUN groupadd -g 33333 gitpod && \
    useradd -u 33333 -g 33333 -m -s /bin/bash gitpod

# gitpod user & sudo
RUN dnf -y install sudo shadow-utils && \
    mkdir -p /etc/sudoers.d && \
    echo "gitpod ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gitpod && \
    chmod 0440 /etc/sudoers.d/gitpodhttps://cloudev.roche.com/workspaces
