path_prepend() {
  [[ ":$PATH:" == *":$1:"* ]] || PATH="$1:$PATH"
}

export EDITOR="vim"
export GEMINI_MODEL="gemini-2.5-flash-lite"
export KATALON_MCP_ENABLED=false
export NVM_DIR="$HOME/.nvm"
export LD_LIBRARY_PATH="$HOME/apps/opt/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

path_prepend "$HOME/apps/opt/bin"

if command -v java >/dev/null 2>&1; then
  JAVA_BIN="$(readlink -f "$(command -v java)")"
  export JAVA_HOME="${JAVA_BIN%/bin/java}"
  path_prepend "$JAVA_HOME/bin"
fi

if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Exit if not interactive
[[ $- != *i* ]] && return
#########################

parse_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  printf '(%s)' "$branch"
}

PS1='[\u@\h \[\e[38;5;246m\]\W\[\e[38;5;238m\]$(parse_git_branch)\[\e[0m\]] \$_$ '

alias neofetch='neofetch --ascii_colors 8 --colors 7 8 7 8 8 7'
alias gitt='git add . && git commit -mm'
alias ll='export JANCOK=1'
# alias man='man -C $HOME/apps/pac/extra/etc/man_db.conf'

nvm() {
  unset -f nvm
  source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

man() {
  command man -C "$HOME/apps/pac/extra/etc/man_db.conf" "$@"
}

v() {
  local dst
  dst="$(command vifm --choose-dir - "$@")" || return

  [[ -z "$dst" ]] && {
    echo "Directory picking cancelled/failed"
      return 1
  }

cd "$dst"
}
