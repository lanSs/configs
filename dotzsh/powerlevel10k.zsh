POWERLEVEL9K_MODE="awesome-patched"
ZSH_THEME="powerlevel10k/powerlevel10k"

if [[ "$OSTYPE" == "linux"* ]]; then
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ `uname -m` == "x86_64" ]]; then
        source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
    else
        source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
    fi
fi

prompt_aws() {
    echo -en "\uE895 [$aws_region_shortname[$AWS_DEFAULT_REGION]]$AWS_PROFILE"
}

POWERLEVEL9K_CUSTOM_AWS="prompt_aws"
POWERLEVEL9K_CUSTOM_AWS_BACKGROUND="red"
POWERLEVEL9K_CUSTOM_AWS_FOREGROUND="white"

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context custom_aws kubecontext newline dir vcs)
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context custom_aws newline dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs)
