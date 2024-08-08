#!/bin/bash

#Needs access to sudo 
#and chmod +x requirement.sh
#instance=""
#zone=""
#gcloud compute ssh --command yes | sudo apt install python3-pip
#sudo apt install python3-pip
#Done
#gcloud compute ssh $instance --zone=$zone --command="pip3 install flask" -- -t

sudo pip3 install flask
sudo pip install requests

#Google Cloud As a back end server: Kubernetes Cluster as front end
sudo python3 BackTodolist.py