module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = false # we don't use a NAT gateway, as it is not free

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}
