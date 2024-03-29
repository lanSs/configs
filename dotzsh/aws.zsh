export AWS_PROFILE="hinge-dev"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials

# keep varibles between session
AWS_PROFILE_TMP="/tmp/aws_profile"
AWS_REGION_TMP="/tmp/aws_region"

if [ -f $AWS_PROFILE_TMP ]; then
    VALUE=$(<$AWS_PROFILE_TMP)
    export AWS_PROFILE=$VALUE
fi

if [ -f $AWS_REGION_TMP ]; then
    VALUE=$(<$AWS_REGION_TMP)
    export AWS_DEFAULT_REGION=$VALUE
fi

declare -A aws_region_shortname
aws_region_shortname=(
    [us-east-1]="ue1"
    [us-east-2]="ue2"
    [us-west-1]="uw1"
    [us-west-2]="uw2"
    [ap-east-1]="ae1"
    [ap-south-1]="as1"
    [ap-northeast-2]="an2"
    [ap-southeast-1]="as1"
    [ap-southeast-2]="as2"
    [ap-northeast-1]="an1"
    [ca-central-1]="cc1"
    [eu-central-1]="ec1"
    [eu-west-1]="ew1"
    [eu-west-2]="ew2"
    [eu-west-3]="ew3"
    [eu-north-1]="en1"
    [me-south-1]="ms1"
    [sa-east-1]="se1"
)

#  Usage: aws-instances [filter]
aws-instances() {
    if [ $# -eq 0 ]; then
        aws ec2 describe-instances --output table                                                                               \
            --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`] | [0].Value,PrivateIpAddress, State.Name]'
    else
        aws ec2 describe-instances --output table                                                                               \
            --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`] | [0].Value,PrivateIpAddress, State.Name]'       \
            --filters "Name=tag:Name,Values=*${1}*"
    fi
}

#  Usage: aws-elb-ips elb-name
aws-elb-ips() {
    if [ $# -eq 0 ]; then
        echo "aws-elb-ips elb-name [public]"
    elif [ $# -eq 1 ]; then
        aws ec2 describe-network-interfaces --filters Name=description,Values="ELB */${1}/*"                                    \
            --query 'NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' --output text
    elif [ "$2" "==" "public" ]; then
        aws ec2 describe-network-interfaces --filters Name=description,Values="ELB */${1}/*"                                    \
            --query 'NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp' --output text
    else
        echo "aws-elb-ips elb-name [public]"
    fi
}

# Usage: aws-connect instance-id
aws-connect() {
    if [ $# -ne 1 ]; then
        echo "aws-connect instance-id"
    elif [[ $1 == i-* ]]; then
        aws ssm start-session --target $1
    else
        echo "Invalid instance id"
    fi
}

# Usage: aws-profile [name] [region]
aws-profile() {
    local yellow darkbg normal
    yellow=$(tput setaf 3 || true)
    darkbg=$(tput setab 0 || true)
    normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then

        for p in $(grep '\[' ~/.aws/config | tr -d '[]' | sed 's/profile //g' | sort -n); do
            if [ "$AWS_PROFILE" = "$p" ]; then
                echo "${darkbg}${yellow}${p}${normal}"
            else
                echo $p
            fi
        done
    else
        if grep '\[' $HOME/.aws/config | tr -d '[]' | sed 's/profile //g' | grep -q "^${1}$"; then 
            echo "Swithing to profile: $1"
            export AWS_PROFILE=$1
            echo -n $1 > $AWS_PROFILE_TMP
        else
            echo "Invalid AWS profile: $1"
        fi

        # region is provided
        if ! [ -z $2 ]; then
            if ! [ -z $aws_region_shortname[$2] ]; then
                echo "Using region: $2"
                export AWS_DEFAULT_REGION=$2
                echo -n $2 > $AWS_REGION_TMP
            else
                echo "Invalid region: $2, ignored"
            fi
        fi
    fi
}

aws-assume-role() {
    local timestamp=$(date +%s)
    local user=$(echo $USER | tr -cd '[a-zA-Z-]')
    if [ $# -ne 1 ]; then
        echo "aws-assume-role role_arn"
    elif [[ "$1" == "unset" ]]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN

        echo "Unset AWS credentials variables"
        local current_role=$(aws sts get-caller-identity | jq '.Arn')
        echo "Current user: $current_role"
    else
        OUTPUT=$(aws sts assume-role                        \
            --role-arn $1                                   \
            --role-session-name $user-local-cli-$timestamp)

        if [ $? ]; then
            local role=$(echo $OUTPUT | jq '.AssumedRoleUser.Arn' | tr -d '"')
            echo "Assumed Role: $role"

            AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq '.Credentials.AccessKeyId' | tr -d '"')
            AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq '.Credentials.SecretAccessKey' | tr -d '"')
            AWS_SESSION_TOKEN=$(echo $OUTPUT | jq '.Credentials.SessionToken' | tr -d '"')
            
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
        fi
   fi
}
