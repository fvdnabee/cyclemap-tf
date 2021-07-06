resource "aws_cloudwatch_log_group" "cyclemap_web" {
  name              = "cyclemap_web"
  retention_in_days = 1
}

data "template_file" "container_definitions" {
  template = file("${path.module}/templates/container_definitions.json")

  vars = {
    MONGODB_URI = var.mongodb_uri
  }
}
resource "aws_ecs_task_definition" "cyclemap-web" {
  family = "cyclemap_web"

  container_definitions = data.template_file.container_definitions.rendered
}

resource "aws_ecs_service" "cyclemap-web" {
  name            = "cyclemap-web"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.cyclemap-web.arn
  tags = {}

  desired_count = 1

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "cyclemap_web"
    container_port   = 8000
  }

  # Work-around for flip-flopping of `capacity_provider_strategy` in ecs
  # services due to only specifying default_capacity_provider_strategy in
  # aws_ecs_cluster and not a capacity_provider_strategy per ECS service
  # See
  # https://github.com/hashicorp/terraform-provider-aws/issues/11351#issuecomment-627632862
  # https://github.com/hashicorp/terraform-provider-aws/issues/11351#issuecomment-656525786
  lifecycle {
    ignore_changes = [
      capacity_provider_strategy
    ]
  }
}
