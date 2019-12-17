export AWS_DEFAULT_PROFILE="hinge-dev"
export AWS_PROFILE=$AWS_DEFAULT_PROFILE

# keep varibles between session
AWS_PROFILE_TMP="/tmp/aws_profile"

if [ -f $AWS_PROFILE_TMP ]; then
    VALUE=$(<$AWS_PROFILE_TMP)
    export AWS_DEFAULT_PROFILE=$VALUE
    export AWS_PROFILE=$VALUE
fi

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
    if [ $# -ne 1 ]; then
        echo "aws-elb-ips elb-name"
    else
        aws ec2 describe-network-interfaces --filters Name=description,Values="ELB */${1}/*"                                    \
            --query 'NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' --output text
    fi
}

# Usage: aws-connect instance-id
aws-connect() {
    if [ $# -ne 1 ]; then
        echo "aws-connect instance-id"
    else
        aws ssm start-session --target $1
    fi
}

# Usage: aws-profile [name]
aws-profile() {
    local yellow darkbg normal
    yellow=$(tput setaf 3 || true)
    darkbg=$(tput setab 0 || true)
    normal=$(tput sgr0 || true)

    if [ $# -eq 0 ]; then

        for p in $(grep '\[' ~/.aws/credentials | tr -d '[]' | sort -n); do
            if [ "$AWS_DEFAULT_PROFILE" = "$p" ]; then
                echo "${darkbg}${yellow}${p}${normal}"
            else
                echo $p
            fi
        done
    else
        if grep '\[' $HOME/.aws/credentials | tr -d '[]' | grep -q "^${1}$"; then 
            echo "Swithing to profile: $1"
            # This is used by SDK
            export AWS_PROFILE=$1
            # This is used by cli
            export AWS_DEFAULT_PROFILE=$1
            echo -n $1 > $AWS_PROFILE_TMP
        else
            echo "Invalid AWS profile: $1"
        fi
    fi
}
