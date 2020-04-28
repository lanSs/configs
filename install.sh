#!/bin/bash

function usage() {
    cat << EOF
install.sh install|uninstall
EOF
    exit 1
}

function replacedot() {
    echo $1 | sed 's/dot/./g'
}

function install() {
    echo "Installing $(replacedot $2)"
    ln -nsf $1/$2 $HOME/$(replacedot $2)
}

function remove() {
    echo "Removing $(replacedot $1)"
    rm -f $HOME/$(replacedot $1)
}

[  $# -ne 1 ] && usage

if [ "$1" = "install" ]; then
    for f in $(find . -maxdepth 1 -name "dot*"); do
        install $(pwd) $(basename $f) 
    done

    echo "Installing & updating the submodules"
    git submodule init
    git submodule update

    unameOut="$(uname -s)"
    if [ "$unameOut" = "Darwin" ]; then
        echo "Installing fonts"
        cp fonts/Droid+Sans+Mono+Awesome.ttf ~/Library/Fonts/Droid+Sans+Mono+Awesome.ttf
        cp fonts/Inconsolata+Awesome.ttf ~/Library/Fonts/Inconsolata+Awesome.ttf
        cp fonts/SourceCodePro+Powerline+Awesome+Regular.ttf ~/Library/Fonts/SourceCodePro+Powerline+Awesome+Regular.ttf
    else
        echo "MANUAL ACTION REQUIRED: please install the fonts in the fonts folder"
    fi
    echo "MANUAL ACTION REQUIRED: implement the steps in the nord-iterm2/README.md to finalise the styling"

elif [ "$1" = "uninstall" ]; then
    for f in $(find . -maxdepth 1 -name "dot*"); do
        remove $(basename $f)  
    done
else
    usage
fi
