#!/bin/bash
#Creating aws instances for robo shop project

SG_ID=sg-0fd437546c9954eac
AMI_ID=ami-0220d79f3f480ecf5
INST_TYPE=t3.micro
ZONEID=Z07306682ZX5MBM0WBCUJ
DOMAINNAME=jaswanthdevops.online
# Run the instance creation command

for instance in $@
do
 INSTANCE=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INST_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text)
if [ $INSTANCE -eq frontned ]; then
             IP=$(aws ec2 describe-instances \
                     --instance-ids $INSTANCE \
                     --query 'Reservations[].Instances[].PublicIpAddress' \
                     --output text)
            RECORD_NM="$INSTANCE.$DOMAINNAME" #Public domain name
    else
             IP=$(aws ec2 describe-instances \
                     --instance-ids $INSTANCE \
                     --query 'Reservations[].Instances[].PrivateIpAddress' \
                     --output text)
             RECORD_NM="$INSTANCE.$DOMAINNAME" #Private domain name
    fi
echo "IP Address: $IP"
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch '
{
  "Comment": "Update A record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$INSTANCE'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }
  ]
}
'
echo "Record updated for $INSTANCE"

done




