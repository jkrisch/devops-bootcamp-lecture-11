#!/usr/bin/bash

export CLUSTERNAME=eks-cluster-jk

eksctl create cluster --name $CLUSTERNAME \
--region eu-central-1  \
--version 1.29 \
--node-type t2.small \
--nodes 3 \
--kubeconfig=.kube/config.$CLUSTERNAME.yaml \
--asg-access


eksctl create fargateprofile \
    --cluster $CLUSTERNAME \
    --name fargate-profile-eks-jk \
    --namespace my-java-app-ns \


export KUBECONFIG=".kube/config.$CLUSTERNAME.yaml"