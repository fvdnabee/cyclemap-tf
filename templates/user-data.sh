#!/bin/bash

# ECS config
# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo "ECS_IMAGE_PULL_BEHAVIOR=always"
} >> /etc/ecs/ecs.config

start ecs

echo "user-data script done"
