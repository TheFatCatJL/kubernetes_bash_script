#!/usr/bin/env bash

# This small utility is for searching your entire kubernetes cluster resources
# It essentially performs kubetcl api-resource | kubectl get | grep

# Usage
usage (){
cat << EOF
usage   : kube-grep -g <grepword> [-n <namespace>] [-k <kind>] [-h]
example : ./kube-grep.sh -g <resource_name>  => return all resources with this name
          ./kube-grep.sh -g <resource_name>  -n <namespace> => return all resources with this name in the target namespace

-g <grepword>      This is a mandatory string to perform grep search
-n <namespace>     Limits searching of resources only to the target namespace
                   Default - ALL namespaces
-k <kind>          Limit only to specified kind using full/shorthand notations of kubernetes eg. secrets,cm,ing
                   Default - grep ALL know kinds in api-resources
-h                 Display usage

EOF
}

kube-grep-every-kind() {
    kubectl api-resources --verbs=list --namespaced -o name | \
    xargs -n 1 kubectl get --ignore-not-found --show-kind -$flag | \
    grep -i -E $grepword | \
    column -t
}

kube-grep-specified-kind() {
    kubectl get $kind -$flag | \
    grep -i -E $grepword | \
    column -t
}

run-main(){
    if [ -z ${namespace} ]; then
        echo "Getting resources across all namespaces..."
        flag=A
    else
        echo "Getting resources across $namespace namespace..."
        flag=$(echo "n $namespace")
    fi

    if [ -z ${kind} ]; then
        echo "Targeting ALL resources"
        kube-grep-every-kind
    else
        echo "Targeting resources : $kind..."
        kube-grep-specified-kind
    fi
}

# getopts
while getopts ":g:n::k::h" opt; do
  case ${opt} in
    g)
      grepword=${OPTARG}
      ;;
    n)
      namespace=${OPTARG}
      ;;
    k)
      kind=${OPTARG}
      ;;
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

if [ ! "$grepword" ]; then
    usage
    exit 1
fi

run-main