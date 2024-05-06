#!/usr/bin/env bash

# This small utility is for cleaning up pods and replicasets
# If you happened to use K8 resources on resources that can disrupt (like spots and preemptibles)
# You can sometimes find dead pods and old replicasets that builds up overtime (well depends alot on other factors as well)

# This is the default pod status for deletion
# Add on if you have other status for pod cleaning
podStatusArray=("Error" "NodeAffinity" "CrashLoop" "Evicted")

usage (){
cat << EOF
usage: kube-clean [-n <namespace>] [-f] [-h]
-n <namespace>     Limits the deleting of replicasets and pods to the target namespace
-f                 Force delete - same as kubectl delete <kind> --force
-h                 Display usage
EOF
}

kubeclean() {
    if [ -z ${nscheck} ]; then
        flag=A
    else
        flag=$(echo "n $nscheck")
    fi

    # First we get rid of unused replicaset
    kubectl get rs --no-headers -o custom-columns=":metadata.name,:metadata.namespace,:status.availableReplicas" -$flag | grep -E "<none>" | 
    while read -a list
    do 
        kubectl delete rs ${list[0]} -n ${list[1]} $forceflag
    done


    # Then we delete the unused pods
    for stringGrep in ${stringArray[@]}; do
        kubectl get pod --no-headers -o custom-columns=":metadata.name,:metadata.namespace" -$flag | grep -E $stringGrep | 
        while read -a list
        do 
            kubectl delete pod ${list[0]} -n ${list[1]} $forceflag
        done
    done
}


# getopts
while getopts ":n::fh" opt; do
  case ${opt} in
    n)
      nscheck=${OPTARG}
      ;;
    f)
      forceflag="--force"
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

kubeclean