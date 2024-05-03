#!/usr/bin/env bash

# Grep keyword
# note case-insensitive
grepword=$1

# By default without a second arg this will work because 
# we will get all the resources that matches the grep search
# user can provide args like secrets,cm,ing to limit the resource scope
kind=${2-'ALL'}

# This will restrict the namespace that the search will be confined to if given
# This arg is more like a limiter for search (might as well just kubectl... ?)
nscheck=${3-'EMPTY'}

flag=A

kube-grep-every-kind() {
    kubectl api-resources --verbs=list --namespaced -o name | \
    xargs -n 1 kubectl get --ignore-not-found --show-kind -$flag | \
    grep -i -E $grepword | \
    column -t
}

if [ ! "$grepword" ]; then
    echo "We need a search string... Try again"
    echo "EXAMPLE >>> ./kube-grep-all.sh <search-string>"
    exit 1
fi

if [ "$nscheck" == "EMPTY" ]; then
    echo "Getting resources across all namespaces..."
else
    echo "Getting resources across $nscheck namespace..."
    flag=$(echo "n $nscheck")
fi

if [ "$kind" == "ALL" ]; then
    echo "Targeting ALL resources"
    kube-grep-every-kind
else
    echo "Targeting resources : $kind..."
    kubectl get $kind -$flag | grep -i -E $grepword | column -t
fi