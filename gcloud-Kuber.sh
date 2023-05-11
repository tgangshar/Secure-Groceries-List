#!/bin/bash
#Deploying a Front end image on kubernetes

#Needs to be edited for each system
#Request name for Instance

#Can be changed in future to involve current directory
PYDIR="C:\Users\Tgang\Classes\5 Grad\Spring2023\Cloud Computing\Final Project\Payload"
#Can also be changed to different ssh keys via "C:\Users\Tgang\.ssh\$2" input
SSHDIR="C:\Users\Tgang\.ssh\gldflask_ssh.pub"

PROJID=cisc5550-380202
ZONE=us-east1
gcloud config set project $PROJID

APPIMG=$ZONE-docker.pkg.dev/$PROJID/todolist/todolist-image:latest
image="tgangshar/frntodolist"

CLUST=todolist-cluster
KUBER=fronttodo-server1

create_instance(){
   echo deleting Compute any Instance: $instance
   gcloud compute instances delete $instance

   echo Creating New Instance: $instance
   gcloud compute instances create $instance --machine-type n1-standard-1 --image-family debian-10 --image-project debian-cloud --tags http-server --metadata-from-file startup-script=./Payload/requirement.sh 

   gcloud compute firewall-rules create rule-allow-tcp-5001 --source-ranges 0.0.0.0/0 --target-tags http-server --allow tcp:5001
   echo Creating new Files to $instance
   gcloud compute os-login ssh-keys add --key-file=$SSHDIR --project=$PROJID --ttl=36d
   gcloud compute scp --recurse  $PYDIR $instance:home/Tgang
   create_image
}

create_image(){
   export TODO_API_IP=`gcloud compute instances list --filter="name=$instance" --format="value(EXTERNAL_IP)"`
   echo
   echo Creating $image with ENV $TODO_API_IP
   echo
   #Make sure to login to docker
   #docker tag $image $image:old
   docker build -t $image:latest --build-arg api_ip=${TODO_API_IP} .
   push_registry
}

push_registry(){
   #gcloud Registry
   #If you need to pull an image not in the directory
   #docker pull docker.io/tgangshar/todolist
   #us-east1-docker.pkg.dev/cisc5550-380202/todolist/todolist-image:latest
   #Enable Artifact API
   gcloud auth configure-docker us-east1-docker.pkg.dev
   #Tag local image to Cloud Image registry
   echo Pushing $APPIMG
   docker tag $image:latest $APPIMG
   docker push $APPIMG
   sleep 5
   #deploy_cluster
}

deploy_cluster(){
   #gcloud container clusters create-auto $CLUST --region=$ZONE

   # Create if statement to check for Cluster

   #Enable GKE API
   #Next step to check deployment method for dockerhub tgangshar/todolist
   gcloud container clusters create $CLUST
   gcloud container clusters get-credentials $CLUST 
   echo Delting deployment: $KUBER
   kubectl delete deployment $KUBER 
   sleep 3
   echo Creating and exposing new Deployment: $KUBER with $APPIMG
   kubectl create deployment $KUBER --image=$APPIMG --port=80
   kubectl expose deployment $KUBER --type LoadBalancer 
   #kubectl create deployment fronttodo-server1 --image=us-east1-docker.pkg.dev/cisc5550-380202/todolist/todolist-image:latest --port=80
   kubectl get service $KUBER
}

read -p "Would you like to start Instance (I), Docker(D), Registry(R) or Cluster(C)? " resp 
read -p "Instance Name: " instance

if [ "$resp" = "I" ]; then 
   create_instance
elif [ "$resp" = "D" ]; then 
   create_image
elif [ "$resp" = "R" ]; then
   push_registry
elif [ "$resp" = "C" ]; then
   deploy_cluster
fi
sleep 3