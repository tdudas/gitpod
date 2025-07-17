#!/bin/bash
set -e

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
rm -rf awscliv2.zip aws

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# kubectx + kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# krew
(
  set -x
  cd "$(mktemp -d)"
  OS=$(uname | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/arm.*$/arm/')
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${OS}_${ARCH}.tar.gz"
  tar zxvf krew-${OS}_${ARCH}.tar.gz
  ./krew-"${OS}_${ARCH}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew install ctx
kubectl krew install ns

# k9s
curl -sSLo k9s.tar.gz "$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep browser_download_url | grep Linux_x86_64.tar.gz | cut -d '"' -f 4)"
tar -xzf k9s.tar.gz && sudo mv k9s /usr/local/bin/ && rm k9s.tar.gz

# istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.21.0 sh -
sudo mv istio-*/bin/istioctl /usr/local/bin/
rm -rf istio-*

# terraform
TERRAFORM_VERSION=1.8.3
curl -sSLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform.zip && sudo mv terraform /usr/local/bin/ && rm terraform.zip

# terragrunt
TG_VERSION="v0.57.4"
curl -sSLo terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64
chmod +x terragrunt && sudo mv terragrunt /usr/local/bin/

# tofu (optional)
curl -s https://raw.githubusercontent.com/opentofu/opentofu/main/install.sh | bash

# Alias setup
cat << 'EOF' >> ~/.bashrc

# AWS profile switcher
alias awsp='export AWS_PROFILE=$(sed -n "s/\\[profile \\(.*\\)\\]/\\1/gp" ~/.aws/config | fzf)'

# Terraform / Terragrunt aliases
alias tf=terraform
alias tg=terragrunt
alias tu=tofu
alias tmp='cd ~/tmp'
alias kge='kubectl get events --sort-by=.metadata.creationTimestamp'

EOF

source ~/.bashrc

# AWS credentials
mkdir -p ~/.aws
cp /workspace/aws-config/* ~/.aws/
