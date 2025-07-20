FROM public.ecr.aws/docker/library/rockylinux:9

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
