# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc
eval "$(/home/gitpod/.local/bin/mise activate bash)"

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

alias ll='ls -lah --color=auto'
alias gs='git status'
alias gp='git pull'
alias gd='git diff'
alias k='kubectl'
alias tf='terraform'
alias py='python3'

alias awsp='export AWS_PROFILE=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | fzf)'
alias a_info="aws --no-cli-pager sts get-caller-identity"
alias a_account_name="aws --no-cli-pager iam list-account-aliases"
alias kge="kubectl get events --sort-by=.metadata.creationTimestamp"
alias kgp="kubectl get pods -o wide"
alias kd="kubectl describe"
alias tf="terraform"
alias tg="terragrunt"
alias tu="tofu"
