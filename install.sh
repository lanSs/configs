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
elif [ "$1" = "uninstall" ]; then
    for f in $(find . -maxdepth 1 -name "dot*"); do
        remove $(basename $f)  
    done
else
    usage
fi
