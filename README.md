# README

## Bash Scripts for Kubernetes Administration Conveniences

Kubernetes command line interface, kubectl, is a powerful and versatile tool for K8s administration.  
This repository will share some bash scripts that has integrated kubectl with some common linux commands / packages.

We have the following:

| Script Name       | Description                                                          | Additional Package |
| ----------------- | -------------------------------------------------------------------- | ------------------ |
| kube-context      | A menu-based kubectl current, get & use context                      | NA                 |
| kube-log          | Output log(s) of pod(s) given search string (name)                   | NA                 |
| kube-desc         | Describe resource(s) given search string (name)                      | NA                 |
| kube-get-all      | Similiar to kubectl get all -A just with grep search built in        | NA                 |
| kube-clean        | Simple dangling pod and rs "cleaner" (spot and preemptibles..)       | NA                 |
| kube-restart      | Menu based kubectl rollout restart RESOURCE for entire namespace     | NA                 |

## Use Alias for better accessibility

One reason why we are scripting is to avoid excessive keystroke activities from repetitive commands.  
We should always explore using alias like the following (for bash shell) to quickly access our script in the command line:

```bash
# This is definitely one of the laziest to do aliasing - and there are better administrative ways
# replace MY_ALIAS_COMMAND_NAME with your desired command name that you want to invoke your target bash script
# replace /<FULL_PATH_TO_TARGET_BASH_SCRIPT> with the actual FULL PATH
echo "alias MY_ALIAS_COMMAND_NAME='bash /<FULL_PATH_TO_TARGET_BASH_SCRIPT>" >> ~/.bashrc
```
