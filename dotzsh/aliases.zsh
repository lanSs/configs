if [[ "$OSTYPE" == "linux"* ]]; then
    alias ls='ls --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
fi

alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias mv='mv -v'
alias cp='cp -v'
