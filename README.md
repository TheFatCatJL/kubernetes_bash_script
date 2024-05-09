# Bash Scripts for Kubernetes Administration Conveniences

## Summary

Kubernetes command line interface, kubectl, is a powerful and versatile tool for K8s administration.  
This repository will share some bash scripts that has integrated kubectl with some common linux commands / packages.

We have the following:

| Script Name       | Description                                                          | Additional Package |
| ----------------- | -------------------------------------------------------------------- | ------------------ |
| kube-context      | A menu-based kubectl current, get & use context                      | NA                 |
| kube-log          | Output log(s) of pod(s) given search string (name)                   | NA                 |
| kube-desc         | Describe resource(s) given search string (name)                      | NA                 |
| kube-grep         | Similiar to kubectl get all -A just with grep search built in        | NA                 |
| kube-clean        | Simple dangling pod and rs "cleaner" (spot and preemptibles..)       | NA                 |
| kube-restart      | Menu based kubectl rollout restart RESOURCE for entire namespace     | NA                 |

### *Use Alias for better accessibility

One reason why we are scripting is to avoid excessive keystroke activities from repetitive commands.  
We should always explore using alias like the following (for bash shell) to quickly access our script in the command line:

```bash
# This assume the target machine you are executing the script in has bash
# Note all scripts uses the bash shebang
# replace MY_ALIAS_COMMAND_NAME with your desired command name that you want to invoke your target bash script
# replace /<FULL_PATH_TO_TARGET_BASH_SCRIPT> with the actual FULL PATH
echo "alias MY_ALIAS_COMMAND_NAME='bash /<FULL_PATH_TO_TARGET_BASH_SCRIPT>" >> ~/.bashrc
```

From hereon, we will assume user has did the aliasing, and we will not mention ./*.sh for less keystrokes sake.

### kube-context

A script to assist users to switch their kubernetes context (i.e. which cluster to connect to) using menu-base selection (console). <br><br>
**Logic => `kubectl config get-contexts | kubectl config use-context`**

```bash
# Minimal Syntax
kube-context

# Follow the menu thereafter
```

### kube-log

During troubleshooting, there are times where the logs of several named pods are required. Instead of kubectl log each and everyone pod, this utility can open up all these pods as long as the keyword (pod name) can be grep. <br>
Furthermore, this utility is also useful for situations where we do several kubectl log for different containers in the pod (sidecars ...) because this utility by default returns ALL containers of the pod.<br><br>
**Logic =>  `kubectl get po -A | grep | kubectl log`**

```bash
# Minimal syntax
# This search for my_super_pod_name in all namespaces, and return the logs (note logs from ALL containers are return by default)
kube-log -g my_super_pod_name

# Same as above, but only the default container log is return.
# Almost the same behaviour as as kubectl get po -A | grep | kubectl log
kube-log -g my_super_pod_name -a false

# This search for my_super_pod_name in my_space namespace, and return the logs from ALL containers in the pod that matches
kube-log -g my_super_pod_name -n my-space
```

### kube-desc

Another utility that arose out of convenience to view description of several same name resources (deploy, svc, ingress etc).<br><br>
**Logic => `kubectl api-resource | kubectl get | grep | kubectl desc`**

```bash
# Minimal syntax
# This search for my_awesome_resource in all namespaces, and return the kubectl describe of all resources in the kubernetes cluster 
kube-desc -g my_awesome_resource

# Same as above, but limits the kinds  (because sometimes we only want ingress & svc <- network troubleshoot)
kube-desc -g my_super_pod_name -k ing,svc

# Same as above, but increase the default limit return of 10 to 50
kube-desc -g my_super_pod_name -k ing,svc -l 50
```

### kube-grep

This utility was intended to get a list of ALL the resources that match the grep name.<br>
There is this `kubectl get all` but we know that is insufficient and `kubectl api-resource | * | *` is so cumbersome to remember.<br><br>
**Logic => `kubectl api-resource | kubectl get | grep`**

```bash
# Minimal syntax
# This search for my_awesome_resource in all namespaces, and return the kubectl get result of all available kinds that matches the grep string
kube-grep -g my_awesome_resource

# Same as above, but limits the kinds  (because sometimes we only want ingress & svc <- network troubleshoot)
kube-grep -g my_super_pod_name -k ing,svc

# SPECIAL KEYWORD
# This is for all those admin that wants to take a status snapshot of ALL their resources
# Recommended to redirect to a file kube-grep -g ADMIN_SNAPSHOT > my-results.txt
kube-grep -g ADMIN_SNAPSHOT
```

### kube-clean

This utility was created for a peculiar side effect of using pre-emptibles (spot) for managed kubernetes in GCP.
Most of the pods are stuck in some NodeAffinity state, and while the new rs is already up and ready, the presence of these pods are quite an eyesore. This script attempts to remove all rs that has no pods (happens also when you do a kubectl rollput restart), and to delete those pesky die-hard pods. <br><br>
**Logic => `kubectl get rs | grep | kubectl delete && kubectl get po | grep | kubectl delete`** 

```bash
# Minimal syntax
# This will delete all empty rs in ALL namespace and delete all pods with the following status in all namespace:
# "Error" "NodeAffinity" "CrashLoop" "Evicted"
kube-clean

# Same as above, but limits the deletion of rs and po to my-space
kube-clean -n my-space

# Same as above, but now we allow the --force arg as per kubectl delete --force
kube-clean -n my-space -f
```

### kube-restart

A utility created for a specific use case - to mass restart deploys, daemonsets, and statefulsets in certain namespaces after a cluster upgrade / common infra service update etc. <br><br>
**Logic => `kubectl get namespace | kubectl get deploy,ds,sts | kubectl rollout restart`**

```bash
# Minimal Syntax
kube-restart

# Follow the menu thereafter
```