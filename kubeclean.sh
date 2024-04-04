#!/usr/bin/env bash

# This small utility is for cleaning up pods and replicasets
# If you happened to use K8 resources on resources that can disrupt (like spots and preemptibles)
# You can sometimes find dead pods and old replicasets that builds up overtime (well depends alot on other factors as well)

# We may want to limit the namespace of our cleaning effort
nscheck=${1-'THISISEMPTY'}

# Uncomment to force delete
# forceflag="--force"

# This is the default pod status for deletion
# Add on if you have other status for pod cleaning
podStatusArray=("Error" "NodeAffinity" "CrashLoop" "Evicted")

flag=A

if [ $nscheck != 'THISISEMPTY' ]; then
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
