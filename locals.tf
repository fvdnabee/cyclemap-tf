locals {
  aws_region  = "eu-west-1"
  aws_profile = "vdna"

  name        = "cyclemap-tf"
  environment = "prod"

  # The key name that should be used for the ASG launch configuration
  asg_lc_key_name = "ec2-fvdnabee-fvdnabee-kp"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"

  # SSL certificate that was created in ACM for map.floriscycles.com
  ssl_certificate_arn = "arn:aws:acm:eu-west-1:184611879143:certificate/9b0ccd0d-f5ae-406f-ab93-ef15ac58fbca"
}
