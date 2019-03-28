#!/bin/sh
kubectl describe secret $(kubectl get secret -n kube-system | grep dashboard-token | awk '{print $1}') -n kube-system
