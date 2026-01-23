#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0ab70a84fcd87cc0d"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z01270651RFKJINNVPOEI"
DOMAIN_NAME="prudhvisai.space"

for instance in ${INSTANCES[@]}
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro 
   --security-group-ids sg-0ab70a84fcd87cc0d --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
      if [ $instance != "frontend" ]
   then
      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
   else
      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
   fi  
   echo "$instance IP address: $IP"
done 