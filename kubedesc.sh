#!/usr/bin/env bash

# # Grep keyword for searching Target Resource NAME
# note case-insensitive
grepword=$1

# This arg will limit the return of results 
# that matches the target NAME using the above keyword
# Default will only return 10 result (the first 10 search)
desc_limit=${2-10}

# By default without a second arg this will work because 
# we will describe all the common resources that matches the name search
# common - pod,svc,deploy,rs,daemonset,ss,cm,secret,ing
# user can provide args like secrets,cm,ing
kind=${3-'ALL'}

# This will restrict the namespace that the search will be confined to if given
# This arg is more like a limiter for search (might as well just kubectl... ?)
nscheck=${4-'EMPTY'}

flag=A

kube_get_describe() {
    desc_num=0
    kubectl get $kind --no-headers -o custom-columns=":metadata.name,:kind,:metadata.namespace" -$flag | grep -i -E $grepword | \
    while read -a list
    do 
        echo
        echo "############### KUBECTL DESCRIBE (${list[1]}) ${list[0]} : ${list[2]} ###############"
        echo
        kubectl describe ${list[1]} ${list[0]} -n ${list[2]};
        desc_num=$((desc_num+=1))
        if [ $desc_num -ge $desc_limit ]; then
            exit 0
        fi
    done
}


if [ "$nscheck" == "EMPTY" ]; then
    echo "Searching for resource descriptions across all namespaces..."
else
    echo "Searching for resource descriptions across $nscheck namespace..."
    flag=$(echo "n $nscheck")
fi

if [ "$kind" == "ALL" ]; then
    echo "Targeting ALL common resources : pod,svc,deploy,rs,daemonset,ss,cm,secrets,ing..."
    kind=all,cm,secret,ing
else
    echo "Targeting resources : $kind..."
fi

kube_get_describe