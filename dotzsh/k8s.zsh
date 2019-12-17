export KUBECTL_CONTEXT=""
export KUBECTL_NAMESPACE="default"

alias kc='kubectl --context="$KUBECTL_CONTEXT" --namespace="$KUBECTL_NAMESPACE"'
alias helm='helm --kube-context $KUBECTL_CONTEXT'

# unset
kubectl config unset current-context > /dev/null

# keep varibles between session
KUBECTL_CONTEXT_TMP="/tmp/kubectl_context"
KUBECTL_NAMESPACE_TMP="/tmp/kubectl_namespace"

if [ -f $KUBECTL_CONTEXT_TMP ]; then
    VALUE=$(<$KUBECTL_CONTEXT_TMP)
    export KUBECTL_CONTEXT=$VALUE
fi

if [ -f $KUBECTL_NAMESPACE_TMP ]; then
    VALUE=$(<$KUBECTL_NAMESPACE_TMP)
    export KUBECTL_NAMESPACE=$VALUE
fi

# Usage: kc-ctx [context]
kc-ctx() {
    local yellow=$(tput setaf 3 || true)
    local darkbg=$(tput setab 0 || true)
    local normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then
        local current_ctx=$(kubectl config view -o=jsonpath='{.current-context}')
        local ctx_list=$(kubectl config get-contexts -o=name | sort -n)

        for c in $ctx_list; do
            if [ "$KUBECTL_CONTEXT" = "$c" ]; then
                echo "${darkbg}${yellow}${c}${normal}"
            else
                echo $c
            fi
        done
    else
        if kubectl config get-contexts -o=name | grep -q "^${1}$"; then
            export KUBECTL_CONTEXT=$1
            echo -n $1 > $KUBECTL_CONTEXT_TMP
            echo "Switched to context: $1"
        else
            echo "Invalid context: $1"
        fi
    fi
}

kc-ctx-unset() {
    export KUBECTL_CONTEXT=""
    rm $KUBECTL_CONTEXT_TMP
    rm $KUBECTL_NAMESPACE_TMP
    # in case the current-context is set externally
    kubectl config unset current-context > /dev/null
}

# Usage: kc-ctx-renamce old new
kc-ctx-rename() {
    if [ $# -ne 2 ]; then
        echo "kc-ctx-rename old new"
    else
        kubectl config rename-context "$1" "$2"
    fi
}

# Usage: kc-ns [namespace]
kc-ns() {
    local yellow=$(tput setaf 3 || true)
    local darkbg=$(tput setab 0 || true)
    local normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then
        for n in $(kubectl --context="$KUBECTL_CONTEXT" get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}'); do
            if [ "$KUBECTL_NAMESPACE" = "$n" ]; then
                echo "${darkbg}${yellow}${n}${normal}"
            else
                echo $n
            fi
        done
    else
        if kubectl --context="$KUBECTL_CONTEXT" get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' | grep -q "^${1}$"; then
            export KUBECTL_NAMESPACE=$1
            echo -n $1 > $KUBECTL_NAMESPACE_TMP
            echo "Switched to namespace: $1"
        else
            echo "Invalid namespace: $1"
        fi
    fi
}


