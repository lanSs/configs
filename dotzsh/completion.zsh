compinit

zstyle ':completion:*:descriptions' format                      \
         "%{$fg[red]%}completing: %B%d%b%{$reset_color%}"
zstyle ':completion:*:warnings' format                          \
         "%{$fg[red]%}No matches for:%{$reset_color%} %d"
zstyle ':completion:*' menu select=2

