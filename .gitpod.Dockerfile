FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  curl unzip git wget software-properties-common \
  vim tmux fzf gnupg lsb-release ca-certificates apt-transport-https \
  && rm -rf /var/lib/apt/lists/*
