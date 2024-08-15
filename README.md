# devops-bootcamp-lecture-11
## Exercise 1: Create EKS Cluster
To create an EKS cluster with 3 Nodes and 1 Fargate Profile you need to specify these requirements within the parameters you pass to eksctl
Note: We are saving the kubeconfig to a seperate file to not overwrite any other kubeconfig file.
Cluster with three managed nodes:
```
cd ~

export CLUSTERNAME=eks-cluster-jk

eksctl create cluster --name $CLUSTERNAME \
--region eu-central-1  \
--version 1.29 \
--node-type t2.small \
--nodes 3 \
--kubeconfig=.kube/config.$CLUSTERNAME.yaml
```

Fargate Profile:
```
eksctl create fargateprofile \
    --cluster $CLUSTERNAME \
    --name fargate-profile-eks-jk \
    --namespace my-java-app \
```

To be able to use kubectl with the respective kubeconfig file:
```
export KUBECONFIG="$HOME/.kube/config.$CLUSTERNAME.yaml"
```

Verification if the cluster is up and running:
```
kubectl get node
kubectl cluster-info

eksctl get fargateprofile --cluster $CLUSTERNAME
```



## Exercise 2: Deploy Mysql and phpmyadmin
**_NOTE_** 
In order to be able to deply the mysql container via helm, we need to create a storageClass.
1. create an IAM OpenID connect issuer (OIDC) provider and attach it to your cluster, you can find further documentation on OIDC issuers (https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).
```
eksctl utils associate-iam-oidc-provider --cluster $CLUSTERNAME --approve
```
2. Then create a service account and attach the EBSDriverPolicy to it. We use the eksutil command to create the IAM role, and attach the IAM policy to it.(see https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html)
```
eksctl create iamserviceaccount   --name ebs-csi-controller-sa   --namespace kube-system   --cluster $CLUSTERNAME   --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy   --approve   --role-only   --role-name AmazonEKS_EBS_CSI_DriverRole
```
3. Add the Amazon EBS CSI driver as an add-on to our cluster, we can do this by running the following command
```
eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTERNAME --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force
```

4. And the last step is to create the storageClass and define it as default storageClass:
```
kubectl apply -f storageClass.yaml
```

Without these steps the pod stayed in the pending stayed and could not provision any pv.

Afterwards we can install the mysql statefulset:
```
helm install --values mysql-values.yaml mysql-jk bitnami/mysql
```
Install phpmyadmin
```
helm install --values phpmyadmin-jk bitnami/phpmyadmin
```

And create a loadbalancer:
```
kubectl apply -f loadbalancer.yaml
```

After that a loadbalancer on EC2 should be created and you can access the phpmyadmin web ui via it's Elastic IP.


## Exercise 3: Deploy your java application

use the helm chart to deploy the app
**_Note_**
I added the loadbalancer yaml to the chart templates, so that a aws loadbalancer is being generated
To access the app add the IP of the loadbalancer to the /etc/hosts file so that the proper hostname is referenced in the request header.
First create 

```
kubectl create ns my-java-app-ns

helm install --namespace my-java-app-ns --values $EXERCISE_HOME/java-app/values.yaml my-java-app java-app
```

## Exercise 4: Automate Deployment
