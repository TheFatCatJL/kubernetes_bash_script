#!/usr/bin/env bash

# Some menu regex
re_env='^[0-9]+$'
re_confirm='^[ynYN]$'

# Print the context menu for user choice
print_context_choice_menu() {
    correct_choice=0
    # We use a while loop to allow for more user behaviours
    while [ $correct_choice == 0 ]
    do
        printf "\n%s\n" "Current context is: $(kubectl config current-context)
You have the following context available:
"
        context_num=0
        for context in ${contexts[@]}; do
            context_num=$((context_num+=1))
            printf "%s\n" "$context_num. $context"
        done
        echo
        read -p  "Enter number from above context menu (1 - $context_num) to switch to: " user_choice

        if ! [[ $user_choice =~ $re_env ]] || [[ $user_choice -gt $context_num ]] || [[ $user_choice -le 0 ]] ; then
            printf "\n%s\n\n" "Please do not choose any number other than 1 to $context_num"
        else
            printf "\n%s\n\n" "Proceeding to switch to context: ${contexts[$user_choice-1]}"
            read -p  "Please confirm [Y/N] (Note any other input will quit here): " user_confirm
            if ! [[ $user_confirm =~ $re_confirm ]] ; then
                "We cannot get your confirmation. Goodbye"
                exit 1
            else
                if [[ $user_confirm == "Y" ]] || [[ $user_confirm == "y" ]] ; then
                    correct_choice=1
                    echo
                    kubectl config use-context ${contexts[$user_choice-1]}
                fi
            fi
        fi
    done
}

# First get the current contexts
kube_context=$(kubectl config get-contexts -no-headers -o name | awk '{print $1}')
IFS=$'\n' read -r -d '' -a contexts <<EOF
${kube_context}
EOF

if [ ! -z "${contexts}" ]; then
    print_context_choice_menu
else
    printf "%s\n" "Sorry, you do not have any kube context defined."
fi