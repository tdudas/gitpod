FROM public.ecr.aws/docker/library/rockylinux:9

RUN dnf -y update && \
    dnf install -y \
      curl unzip git wget \
      vim tmux fzf \
      tar gzip findutils shadow-utils \
      which hostname \
      dnf-plugins-core \
      bash-completion \
      sudo \
      && dnf clean all
