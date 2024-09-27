#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <discovery-name> <ecs-service-name>"
    exit 1
fi

DISCOVERY_NAME="$1"
ECS_SERVICE_NAME="$2"
CLUSTER_NAME="MainCluster"

# Look up the service ID using the discovery name
SERVICE_ID=$(aws servicediscovery list-services --filters Name="NAME",Values="$DISCOVERY_NAME",Condition="EQ" --query 'Services[0].Id' --output text)

if [ -z "$SERVICE_ID" ]; then
    echo "Failed to find service ID for discovery name: $DISCOVERY_NAME"
    exit 1
fi

# Get the first task ARN for the ECS service
TASK_ARN=$(aws ecs list-tasks --cluster "$CLUSTER_NAME" --service-name "$ECS_SERVICE_NAME" --query 'taskArns[0]' --output text)

if [ -z "$TASK_ARN" ]; then
    echo "No tasks found for the ECS service"
    exit 1
fi

# Get the task details
TASK_DETAILS=$(aws ecs describe-tasks --cluster "$CLUSTER_NAME" --tasks "$TASK_ARN")

# Extract the private IP of the task
PRIVATE_IP=$(echo "$TASK_DETAILS" | jq -r '.tasks[0].containers[0].networkInterfaces[0].privateIpv4Address')

if [ -z "$PRIVATE_IP" ]; then
    echo "Failed to get private IP for the task"
    exit 1
fi

# Find the instance ID in Cloud Map using the private IP
INSTANCE_ID=$(aws servicediscovery list-instances --service-id "$SERVICE_ID" | jq -r --arg IP "$PRIVATE_IP" '.Instances[] | select(.Attributes.AWS_INSTANCE_IPV4 == $IP) | .Id')

if [ -z "$INSTANCE_ID" ]; then
    echo "Failed to find instance ID in Cloud Map"
    exit 1
fi

# Deregister the instance
aws servicediscovery deregister-instance --service-id "$SERVICE_ID" --instance-id "$INSTANCE_ID"

echo "Deregistered instance $INSTANCE_ID from service $SERVICE_ID (Discovery name: $DISCOVERY_NAME)"