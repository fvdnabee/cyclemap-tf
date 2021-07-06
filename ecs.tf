#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = local.name

  # CloudWatch Container Insights is a monitoring and troubleshooting solution
  # for containerized applications and microservices. It collects, aggregates,
  # and summarizes compute utilization such as CPU, memory, disk, and network;
  # and diagnostic information such as container restart failures to help you
  # isolate issues with your clusters and resolve them quickly.
  container_insights = false

  # As fargate appears to fall outside the AWS free tier, we don't use it
  capacity_providers = [aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [{
    base              = "0"
    capacity_provider = aws_ecs_capacity_provider.prov1.name
    weight            = "1"
  }]

  tags = {
    Environment = local.environment
  }
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"
  tags = {}

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }

}

#----- ECS  Services--------
variable "mongodb_uri" {
  description = "mongodb URI to set as MONGODB_URI env variable"
  type        = string
  sensitive   = true
}

module "cyclemap" {
  source = "./modules/ecs-service-cyclemap"

  cluster_id = module.ecs.ecs_cluster_id
  # Set via an env variable:
  # export TF_VAR_username="mongodb://user:password@host/database"
  mongodb_uri = var.mongodb_uri

  lb_target_group_arn = aws_lb_target_group.hypercorn-target-group.arn
}
