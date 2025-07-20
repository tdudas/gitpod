#!/bin/bash
set -e

# Upewnij się, że system jest zaktualizowany
sudo dnf update -y
sudo dnf install -y dnf-plugins-core curl unzip git vim tmux tar findutils

# EPEL dla fzf
sudo dnf install -y epel-release
sudo dnf install -y fzf

# Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# kubectx / kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# krew (kubectl plugin manager)
(
  set -x
  cd "$(mktemp -d)"
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m | sed 's/x86_64/amd64/')"
  KREW="krew-${OS}_${ARCH}"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  tar zxvf "${KREW}.tar.gz"
  ./"${KREW}" install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
)

# k9s
curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
tar -xzf k9s.tar.gz k9s
chmod +x k9s
sudo mv k9s /usr/local/bin/
rm -f k9s.tar.gz

# istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.22.0 sh -
sudo mv istio-1.22.0/bin/istioctl /usr/local/bin/
rm -rf istio-1.22.0

# terraform
TF_VERSION="1.8.5"
curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip terraform_${TF_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TF_VERSION}_linux_amd64.zip

# terragrunt
TG_VERSION="0.56.3"
curl -Lo terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_amd64"
chmod +x terragrunt
sudo mv terragrunt /usr/local/bin/

# ArgoCD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# AWS CDK v2
sudo npm install -g aws-cdk@2

# Aliasy
echo '
# Custom aliases
alias tf="terraform"
alias tg="terragrunt"
alias tmp="cd ~/tmp"
alias tu="tofu"
alias kge="kubectl get events --sort-by=.metadata.creationTimestamp"
alias awsp='\''export AWS_PROFILE=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | fzf)'\'
' >> ~/.bashrc

# Załaduj aliasy
source ~/.bashrc

echo "Instalation completed."
