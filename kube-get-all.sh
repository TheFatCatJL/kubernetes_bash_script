#!/usr/bin/env bash

# Grep keyword
# note case-insensitive
grepword=$1

# By default without a second arg this will work because 
# we will get all the common resources that matches the name search
# common - pod,svc,deploy,rs,daemonset,ss,cm,secret,ing
# user can provide args like secrets,cm,ing
kind=${2-'ALL'}

# This will restrict the namespace that the search will be confined to if given
# This arg is more like a limiter for search (might as well just kubectl... ?)
nscheck=${3-'EMPTY'}

flag=A

if [ ! "$grepword" ]; then
    echo "We need a search string... Try again"
    echo "EXAMPLE >>> ./kube-get-all.sh <search-string>"
    exit 1
fi

if [ "$nscheck" == "EMPTY" ]; then
    echo "Getting resources across all namespaces..."
else
    echo "Getting resources across $nscheck namespace..."
    flag=$(echo "n $nscheck")
fi

if [ "$kind" == "ALL" ]; then
    echo "Targeting ALL common resources : pod,svc,deploy,rs,daemonset,ss,cm,secrets,ing..."
    kind=all,cm,secret,ing
else
    echo "Targeting resources : $kind..."
fi

kubectl get $kind -$flag | grep -i -E $grepword | column -t