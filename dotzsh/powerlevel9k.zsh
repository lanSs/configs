if [[ "$OSTYPE" == "linux"* ]]; then
    source /usr/share/zsh-theme-powerlevel9k/powerlevel9k.zsh-theme
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source /usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme
fi

ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="awesome-fontconfig"

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context aws kubecontext newline dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs)
