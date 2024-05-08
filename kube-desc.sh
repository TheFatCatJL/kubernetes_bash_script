#!/usr/bin/env bash

# This small utility is for perform kubectl get | grep | kubectl desc in sucession
# Useful for debugging siutations where you know you know the resource names (not the random part).

# Usage
usage (){
cat << EOF
usage   : kube-desc -g <grepword> [-n <namespace>] [-k <kind>] [l <limit>] [-h]
example : ./kube-desc.sh -g <resource_name>  => return kubectl describe of all resources with this name in all namespaces
          ./kube-desc.sh -g <resource_name>  -n <namespace> => return kubectl describe of all resources with this name in the target namespace
          ./kube-desc.sh -g <resource_name>  -k <kind> -l 2 => return kubectl describe of all resources with this name and kind, limiting to 2 results

-g <grepword>      This is a mandatory string to perform grep search
-n <namespace>     Limits searching of resources only to the target namespace
                   Default - ALL namespaces
-k <kind>          Limit only to specified kind using full/shorthand notations of kubernetes eg. secrets,cm,ing
                   Default - grep ALL know kinds in api-resources
-l <limit>         This impose a limit on the number of results (due to how extensive is each kubectl describe)
                   Deafult - limits result displayed up to 10
-h                 Display usage

EOF
}

kube-desc-every-kind() {
    kubectl api-resources --verbs=list --namespaced -o name  | \
    xargs -n 1 kubectl get --ignore-not-found --show-kind -$flag -o custom-columns=":metadata.namespace,:metadata.name,:kind" | \
    grep -i -E $grepword | \
    while read -a list
    do 
        echo
        echo "############### KUBECTL DESCRIBE (${list[2]}) - ${list[1]} : ${list[0]} ###############"
        echo
        kubectl describe ${list[2]} ${list[1]} -n ${list[0]};
        desc_num=$((desc_num+=1))
        if [ $desc_num -ge $desc_limit ]; then
            exit 0
        fi
    done
}

kube-desc-specified-kind() {
    kubectl get $kind -$flag --ignore-not-found --show-kind -o custom-columns=":metadata.namespace,:metadata.name,:kind"  | \
    grep -i -E $grepword | \
    while read -a list
    do 
        echo
        echo "############### KUBECTL DESCRIBE (${list[2]}) - ${list[1]} : ${list[0]} ###############"
        echo
        kubectl describe ${list[2]} ${list[1]} -n ${list[0]};
        desc_num=$((desc_num+=1))
        if [ $desc_num -ge $desc_limit ]; then
            exit 0
        fi
    done
}

run-main(){
    if [ -z ${namespace} ]; then
        echo "Searching for resource descriptions across all namespaces..."
        flag=A
    else
        echo "Searching for resource descriptions across $namespace namespace..."
        flag=$(echo "n $namespace")
    fi

    if [ -z ${kind} ]; then
        echo "Targeting ALL resources"
        kube-desc-every-kind
    else
        echo "Targeting resources : $kind..."
        kube-desc-specified-kind
    fi
}

# getopts
while getopts ":g:n::k::l::h" opt; do
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
    l)
      desc_limit=${OPTARG}
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