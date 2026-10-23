export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# CASE_SENSITIVE="true"
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 1  # frequency auto update
zstyle ':omz:update' cooldown 1 # how long an update before getting applied

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

ENABLE_CORRECTION="false" # enable or disable auto-correction

COMPLETION_WAITING_DOTS="true"

plugins=(
    git
    asdf
    vi-mode
)

source $ZSH/oh-my-zsh.sh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="/home/fzr/.local/bin:$PATH"
export EDITOR='nvim' # default editor
export ARCHFLAGS="-arch $(uname -m)"

alias vim="nvim"
alias lg="lazygit"
alias zshc="vim ~/.zshrc"
