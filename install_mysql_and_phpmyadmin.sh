#!/usr/bin/bash

#deploy mysql container
helm install --values $EXERCISE_HOME/mysql-values.yaml mysql-jk bitnami/mysql


#deploy myphpadmin
helm install --values $EXERCISE_HOME/phpmyadmin-values.yaml phpmyadmin-jk bitnami/phpmyadmin
kubectl apply -f $EXERCISE_HOME/loadbalancer.yaml


#deploy java app
kubectl create ns my-java-app-ns
helm install --namespace my-java-app-ns --values $EXERCISE_HOME/java-app/values.yaml my-java-app java-app

