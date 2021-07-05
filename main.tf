terraform {
  backend "s3" {
    bucket  = "cyclemap-tfstate" # bucket created in AWS console, ensure to enable Bucket Versioning
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    profile = "vdna"
  }
}

provider "aws" {
  region  = local.aws_region
  profile = local.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}
