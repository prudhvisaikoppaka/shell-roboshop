#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-01431a141b5a82d24"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z08496491D9BJEMR7DC94"
DOMAIN_NAME="prudhvisai.space"

#for instance in ${INSTANCES[@]} for all instances creation at once
for instance in $@ #for individual instance creation 
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro  --security-group-ids sg-01431a141b5a82d24 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
   if [ $instance != "frontend" ]
   then
      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
      RECORD_NAME="$instance.$DOMAIN_NAME"
   else
      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
      RECORD_NAME="$DOMAIN_NAME"
   fi  
   echo "$instance IP address: $IP"

   aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID --change-batch '
   {
       "Comment": "Creating or Updating a record set for cognito endpoint",
       "Changes": [{
       "Action"           : "UPSERT",
       "ResourceRecordSet": {
         "Name"            : "'$RECORD_NAME'",
         "Type"            : "A",
         "TTL"             : 1,
         "ResourceRecords" : [{ 
            "Value"        : "'$IP'"
         }]
      }
      }]
   }'
done 