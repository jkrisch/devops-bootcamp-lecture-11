#!/usr/bin/bash

export EXERCISE_HOME=$HOME/devopsbootcamp/devops-bootcamp-lecture-11

eksctl utils associate-iam-oidc-provider --cluster $CLUSTERNAME --approve

eksctl create iamserviceaccount   --name ebs-csi-controller-sa   --namespace kube-system   --cluster $CLUSTERNAME   --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy   --approve   --role-only   --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTERNAME --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force

kubectl apply -f $EXERCISE_HOME/storageClass.yaml

