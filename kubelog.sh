#!/usr/bin/env bash

# This arg will check for the keyword that is used for searching POD NAME
grepword=$1

# This arg will limit the return of results of the logs of 
# pods that matches the POD NAME using the above keyword
# Default will only return 1 result (the first 10 search)
log_limit=${2-10}

# This will restrict the namespace that the search will be confined to if given
# This arg is more like a limiter for search (migh as well just kubectl)
nscheck=${3-'EMPTY'}

kubelog-all() {
    log_num=0
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -A | grep $grepword | \
    while read -a list
    do 
        echo
        echo "############### LOG FROM ${list[0]} : ${list[1]} ###############"
        echo
        kubectl logs ${list[0]} -n ${list[1]};
        log_num=$((log_num+=1))
        if [ $log_num -ge $log_limit ]; then
            exit 0
        fi
    done
}

kubelog-ns() {
    log_num=0
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -n $nscheck | grep $grepword | \
    while read -a list
    do 
        echo
        echo "############### LOG FROM ${list[0]} : ${list[1]} ###############"
        echo
        kubectl logs ${list[0]} -n ${list[1]}
        log_num=$((log_num+=1))
        if [ $log_num -ge $log_limit ]; then
            exit 0
        fi
    done
}

echo "Limiting to only first $log_limit logs..."
if [ "$nscheck" == "EMPTY" ]; then
    echo "Searching for logs across all namespaces..."
    kubelog-all
else
    echo "Searching for logs across $nscheck namespace..."
    kubelog-ns
fi