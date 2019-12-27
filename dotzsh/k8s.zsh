alias kc='kubectl'

# Usage: kc-ctx [context]
kc-ctx() {
    local yellow=$(tput setaf 3 || true)
    local darkbg=$(tput setab 0 || true)
    local normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then
        local current_ctx=$(kubectl config view -o=jsonpath='{.current-context}')
        local ctx_list=$(kubectl config get-contexts -o=name | sort -n)

        for c in $ctx_list; do
            if [ "$current_ctx" = "$c" ]; then
                echo "${darkbg}${yellow}${c}${normal}"
            else
                echo $c
            fi
        done
    else
        if kubectl config get-contexts -o=name | grep -q "^${1}$"; then
            kubectl config use-context $1 > /dev/null
            echo "Switched to context: $1"
        else
            echo "Invalid context: $1"
        fi
    fi
}

kc-ctx-unset() {
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

    local current_ctx=$(kubectl config view -o=jsonpath='{.current-context}')
    local current_ns=$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${current_ctx}\")].context.namespace}")

    if [ $# -eq 0 ]; then
        for n in $(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}'); do
            if [ "$current_ns" = "$n" ]; then
                echo "${darkbg}${yellow}${n}${normal}"
            else
                echo $n
            fi
        done
    else
        if kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' | grep -q "^${1}$"; then
            kubectl config set-context $current_ctx --namespace $1 > /dev/null
            echo "Switched to namespace: $1"
        else
            echo "Invalid namespace: $1"
        fi
    fi
}


