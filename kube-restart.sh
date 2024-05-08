#!/usr/bin/env bash

# This small utility is for perform kubectl restart using a simple console menu

# Usage
usage (){
cat << EOF
usage   : kube-restart [-h]
example : ./kube-restart.sh     (follow the menu)

-h                 Display usage

EOF
}

# getopts
while getopts ":h" opt; do
  case ${opt} in
    h)
      usage
      exit 0
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Some menu regex
re_env='^[0-9]+$'
re_confirm='^[ynYN]$' 

# vars
resource_choice='ALL'
ns_choice='default'

print_preface_menu() {
cat << EOF

This utility is used to perform the following:
kubectl rollout restart 
on deployments, daemonset, statefulset
in the target namespace.

EOF
}

print_namespace_choice_menu() {
    # Print ns menu
    # get user choice for namespace
    correct_choice=0
    while [ $correct_choice == 0 ]
    do
        printf "%s\n" "Please choose TARGET NAMESPACE"
        loopint=0
        for loopns in ${namespaces[@]}; do
            loopint=$((loopint+=1))
            printf "%s\n" "$loopint. $loopns"
        done
        echo
        read -p  "Enter number from above menu (1 - $loopint) : " user_ns_choice
        if ! [[ $user_ns_choice =~ $re_env ]] || [[ $user_ns_choice -gt $loopint ]] || [[ $user_ns_choice -le 0 ]] ; then
            printf "\n%s\n\n" "Please do not choose any number other than 1 to $loopint"
        else
            ns_choice=${namespaces[user_ns_choice-1]}
            correct_choice=1
        fi
    done
}

print_resource_choice_menu() {
    # Print ns menu
    # get user choice for namespace
    correct_choice=0
    while [ $correct_choice == 0 ]
    do
        printf "%s\n" "Please choose TARGET resources"
        resourcesArray=("ALL" "deployment" "daemonset" "statefulset")
        loopint=0
        for loopns in ${resourcesArray[@]}; do
            loopint=$((loopint+=1))
            printf "%s\n" "$loopint. $loopns"
        done
        echo
        read -p  "Enter number from above menu (1 - $loopint) : " user_resource_choice
        if ! [[ $user_resource_choice =~ $re_env ]] || [[ $user_resource_choice -gt $loopint ]] || [[ $user_resource_choice -le 0 ]] ; then
            printf "\n%s\n\n" "Please do not choose any number other than 1 to $loopint"
        else
            resource_choice=${resourcesArray[user_resource_choice-1]}
            correct_choice=1
        fi
    done
}

get_and_rollout_resource() {
    kubectl get $target_resource --no-headers -o custom-columns=":metadata.name" -n $ns_choice | \
    while read -a list
    do 
        kubectl rollout restart $target_resource -n $ns_choice ${list[0]}
        # if you want to rollout faster, adjust below sleep value
        sleep 5
    done
}
    

# get all current namespace
# First get the current contexts
kube_ns=$(kubectl get namespace -no-headers -o custom-columns=":metadata.name" | awk '{print $1}')
IFS=$'\n' read -r -d '' -a namespaces <<EOF
${kube_ns}
EOF
print_preface_menu
print_namespace_choice_menu
print_resource_choice_menu

if [[ "$resource_choice" == "ALL" ]]; then
    for current_resource in "deployment" "daemonset" "statefulset"
    do
        target_resource=$current_resource
        get_and_rollout_resource
    done
else
    target_resource=$resource_choice
    get_and_rollout_resource
fi