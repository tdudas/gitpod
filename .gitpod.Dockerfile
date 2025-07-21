FROM public.ecr.aws/docker/library/rockylinux:9

# add gitpod sudo
RUN echo "gitpod:x:33333:33333::/home/gitpod:/bin/bash" >> /etc/passwd && \
    echo "gitpod:x:33333:" >> /etc/group && \
    echo "gitpod ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gitpod && \
    chmod 0440 /etc/sudoers.d/gitpod

RUN dnf install -y epel-release

RUN dnf -y update && \
    dnf install -y --allowerasing \
      unzip git wget \
      curl vim tmux fzf \
      bind-utils \
      tar gzip findutils shadow-utils \
      which hostname \
      dnf-plugins-core \
      bash-completion \
      sudo \
      && dnf clean all
