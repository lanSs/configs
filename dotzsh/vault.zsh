declare -A vault_profile_mapping
vault_profile_mapping=(
    [hinge-dev]="https://dev-ue1-vault.hingedev.net"
    [hinge-dev-sso]="https://dev-ue1-vault.hingedev.net"
    [hinge-qa]="https://qa-ue1-vault.hingeqa.net"
    [hinge-qa-sso]="https://qa-ue1-vault.hingeqa.net"
    [hinge-prod]="https://prod-ue1-vault.hingeprod.net"
    [hinge-prod-sso]="https://prod-ue1-vault.hingeprod.net"
    [hinge-sec]="https://sec-ue1-vault.hingesec.net"
    [hinge-sec-sso]="https://sec-ue1-vault.hingesec.net"
)

export VAULT_PROFILE="hinge-dev"
export VAULT_ADDR=$vault_profile_mapping[$VAULT_PROFILE]

# keep varibles between session
VAULT_PROFILE_TMP="/tmp/vault_profile"

if [ -f $VAULT_PROFILE_TMP ]; then
    VALUE=$(<$VAULT_PROFILE_TMP)
    export VAULT_PROFILE=$VALUE
    export VAULT_ADDR=$vault_profile_mapping[$VAULT_PROFILE]
fi

# Usage: vault-profile [name]
vault-profile() {
    local profiles="hinge-dev hinge-dev-sso hinge-qa hinge-qa-sso hinge-prod hinge-prod-sso hinge-sec hinge-sec-sso"

    local yellow darkbg normal
    yellow=$(tput setaf 3 || true)
    darkbg=$(tput setab 0 || true)
    normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then
        for p in $profiles; do
            if [ "$VAULT_PROFILE" = "$p" ]; then
                echo "${darkbg}${yellow}${p}${normal}"
            else
                echo $p
            fi
        done
    else
        if ! [ -z $vault_profile_mapping[$1] ]; then
            echo "Switching to profile: $1"
            export VAULT_PROFILE=$1
            export VAULT_ADDR=$vault_profile_mapping[$1]
        else
            echo "Invalid Vault profile: $1"
        fi
    fi
}

# Usage: vault-login [role]
vault-login() {
    local header=$(echo $VAULT_ADDR | awk -F/ '{ print $3; }')
    local role="administrators"

    if ! [ -z $1 ]; then
        role=$1
    fi

    echo "Using Vault profile: $VAULT_PROFILE, role: $role"

    export AWS_PROFILE=$VAULT_PROFILE
    export AWS_DEFAULT_PROFILE=$VAULT_PROFILE

    env | grep AWS
    vault login -method=aws header_value=$header role=$role
}
