
# Exit if not interactive
[[ $- != *i* ]] && return

parse_git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/(\1)/p'
}

#PS1='$(parse_git_branch)[\u@\h \W]\$ '
#PS1='[\u@\h \W]$(parse_git_branch)\$ '
PS1='[\u@\h \[\e[38;5;246m\]\W\[\e[38;5;238m\]$(parse_git_branch)\[\e[0m\]] \$_$ '

alias neofetch='neofetch --ascii_colors 8 --colors 7 8 7 8 8 7'
alias gitt='git add . && git commit -mm'
alias ll='export JANCOK=1'

export EDITOR="vim"
export GEMINI_MODEL="gemini-2.5-flash-lite"
export PATH="$PATH:/home/noodle/apps/opt/bin/"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/noodle/apps/opt/lib/"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
# [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

v() {
    local dst
    dst="$(command vifm --choose-dir - "$@")" || return
    [[ -z "$dst" ]] && {
        echo "Directory picking cancelled/failed"
        return 1
    }
    cd "$dst"
}

#export PATH="$PATH:$HOME/apps/bin"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/apps/lib"
#export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"
#export C_INCLUDE_PATH="$HOME/.local/include:$C_INCLUDE_PATH"
#export CPLUS_INCLUDE_PATH="$HOME/.local/include:$CPLUS_INCLUDE_PATH"

