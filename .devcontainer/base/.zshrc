#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
export LANG=ja_JP.UTF-8
alias d="docker"
alias dc="docker compose"
alias ll="ls -AlF"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
