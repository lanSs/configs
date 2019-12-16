bindkey -e

bindkey "\e[1~" beginning-of-line
bindkey "\e[7~" beginning-of-line

bindkey "\e[4~" end-of-line
bindkey "\e[8~" end-of-line

bindkey "\e[3~" delete-char

bindkey '^[[A' up-line-or-search                                                
bindkey '^[[B' down-line-or-search
