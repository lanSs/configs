export KUBECTL_CONTEXT="dev-eks-02"
export KUBECTL_NAMESPACE="hinge-services"

alias kc='kubectl --context="$KUBECTL_CONTEXT" --namespace="$KUBECTL_NAMESPACE"'

# unset
kubectl config unset current-context > /dev/null

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
            echo "Switched to context: $1"
        else
            echo "Invalid context: $1"
        fi
    fi
}

# Usage: kc-ctx-renamce old new
kc-ctx-rename() {
    if [ $# -ne 2 ]; then
        echo "kc-ctx-rename old new"
    else
        kubectx config rename-context "$1" "$2"
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
            echo "Switched to namespace: $1"
        else
            echo "Invalid namespace: $1"
        fi
    fi
}


