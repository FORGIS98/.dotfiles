
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='emacs'
fi

export PATH=$PATH:~/.config/emacs/bin
export JAVA_HOME="/usr/lib/jvm/java-25-openjdk"

alias yay="yay --needed"
alias k="kubectl"

extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

bindkey "^k" up-line-or-beginning-search
if [[ "$INSIDE_EMACS" != 'vterm' ]]; then
    bindkey "^j" down-line-or-beginning-search
fi

zstyle :omz:plugins:ssh-agent identities id_ed25519
zstyle :omz:plugins:ssh-agent lifetime 8h

function list_all_on_cd() {
    ls -F --color=auto
}

add-zsh-hook chpwd list_all_on_cd

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="yyyy-mm-dd"
setopt EXTENDED_HISTORY          # Write timestamp
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_FIND_NO_DUPS         # Don't show duplicates in search
setopt HIST_REDUCE_BLANKS        # Remove unnecessary blanks
setopt SHARE_HISTORY             # Share history across terminals

source <(fzf --zsh)

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
