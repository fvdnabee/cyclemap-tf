#----- ECS  Resources--------

# For now we only use the AWS ECS optimized ami
# <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "ec2_profile" {
  source = "./modules/ecs-instance-profile"

  name = local.name

  tags = {
    Environment = local.environment
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = local.ec2_resources_name

  # Launch configuration
  lc_name   = local.ec2_resources_name
  use_lc    = true
  create_lc = true

  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t3.micro"
  security_groups           = [module.vpc.default_security_group_id]
  iam_instance_profile_name = module.ec2_profile.iam_instance_profile_id
  user_data                 = data.template_file.user_data.rendered

  # Auto scaling group
  # Internet access is required for our EC2 instances as cyclemap connects to
  # an external MongoDB database hosted by MongoDB Atlas cloud.
  # It would be safer if our EC2 instances did not have a public IP address.
  # Internet access without a public IP requires provisioning a NAT gateway or
  # dedicating an EC2 instance as a NAT instance however. Both options fall
  # outside the AWS Free tier however.
  # So instead we just assign public addresses to our instances and don't use a
  # NAT gateway, to remain in the AWS free tier.
  # vpc_zone_identifier       = module.vpc.private_subnets
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  # Application load balancer (ALB)
  target_group_arns = ["${aws_lb_target_group.hypercorn-target-group.arn}"]

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = local.name
  }
}
