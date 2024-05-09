#!/usr/bin/env bash

# This small utility is for perform kubectl get po | grep | kubectl log in sucession
# Useful for debugging siutations where you know you apparently know the resource names (not the random part).

# Usage
usage (){
cat << EOF
usage   : kube-log -g <grepword> [-n <namespace>] [-l <limit>] [-a <all>] [-h]
example : ./kube-log.sh -g <pod_name>  => return kubectl log of pod(s) with this name
          ./kube-log.sh -g <pod_name>  -n <namespace> => return kubectl log of pod(s) with this name in the target namespace

-g <grepword>      This is a mandatory string to perform grep search
-n <namespace>     Limits searching of resources only to the target namespace
                   Default - ALL namespaces
-l <limit>         This impose a limit on the number of results (due to how extensive is each kubectl log is)
                   Deafult - limits result displayed up to 5
-a <all>           By default kubectl log only returns the logs of the default container, for those multi-container pods, using this will return logs of ALL containers
                   Use only true or false. DEFAULT - true
-h                 Display usage

EOF
}

kubelog-all() {
    log_num=0
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -A | grep -i -E $grepword | \
    while read -a list
    do 
      if [[ "$all_containers" = true ]]; then
        kubectl get po ${list[0]} -n ${list[1]} -o=jsonpath='{.spec.containers[*].name}' | \
        xargs -n 1 | \
        while read -a innerlist
        do
          echo
          echo "############### LOG FROM POD ${list[0]} (C: ${innerlist[0]}) | NS: ${list[1]} ###############"
          echo
          kubectl logs ${list[0]} -n ${list[1]} -c ${innerlist[0]};
          log_num=$((log_num+=1))
          if [[ $log_num -ge $log_limit ]]; then
            exit 0
          fi
        done
      else
        echo
        echo "############### LOG FROM POD ${list[0]} | NS: ${list[1]} ###############"
        echo
        kubectl logs ${list[0]} -n ${list[1]};
        log_num=$((log_num+=1))
        if [[ $log_num -ge $log_limit ]]; then
          exit 0
        fi
      fi
    done
}

kubelog-ns() {
    log_num=0
    kubectl get pods --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -n $namespace | grep -i -E $grepword | \
    while read -a list
    do
      if [ "$all_containers" = true ]; then
        kubectl get po ${list[0]} -n ${list[1]} -o=jsonpath='{.spec.containers[*].name}' | \
        xargs -n 1 | \
        while read -a innerlist
        do
          echo
          echo "############### LOG FROM POD ${list[0]} (C: ${innerlist[0]}) | NS: ${list[1]} ###############"
          echo
          kubectl logs ${list[0]} -n ${list[1]}
          log_num=$((log_num+=1))
          if [[ $log_num -ge $log_limit ]]; then
            exit 0
          fi
        done
      else
        echo
        echo "############### LOG FROM POD ${list[0]} | NS: ${list[1]} ###############"
        echo
        kubectl logs ${list[0]} -n ${list[1]}
        log_num=$((log_num+=1))
        if [[ $log_num -ge $log_limit ]]; then
          exit 0
        fi
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
while getopts ":g:n::k::l::a::h" opt; do
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
    a)
      all_containers=${OPTARG}
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

if [ ! "$all_containers" ]; then
  all_containers=true
fi

if [ ! "$log_limit" ]; then
  log_limit=5
fi

run-main