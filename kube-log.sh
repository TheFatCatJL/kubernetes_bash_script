#!/usr/bin/env bash

# This small utility is for perform kubectl get po | grep | kubectl log in sucession
# Useful for debugging siutations where you know you apparently know the resource names (not the random part).

# Usage
usage (){
cat << EOF
usage   : kube-log -g <grepword> [-n <namespace>] [-l <limit>] [-h]
example : ./kube-log.sh -g <resource_name>  => return kubectl log of pod(s) with this name
          ./kube-log.sh -g <resource_name>  -n <namespace> => return kubectl log of pod(s) with this name in the target namespace

-g <grepword>      This is a mandatory string to perform grep search
-n <namespace>     Limits searching of resources only to the target namespace
                   Default - ALL namespaces
-l <limit>         This impose a limit on the number of results (due to how extensive is each kubectl describe)
                   Deafult - limits result displayed up to 1
-h                 Display usage

EOF
}

kubelog-all() {
    log_num=0
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -A | grep -i -E $grepword | \
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
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -n $namespace | grep -i -E $grepword | \
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

run-main(){
    if [ -z ${namespace} ]; then
        echo "Searching for logs across all namespaces..."
        kubelog-all
    else
        echo "Searching for logs across $namespace namespace..."
        kubelog-ns
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
    l)
      log_limit=${OPTARG}
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