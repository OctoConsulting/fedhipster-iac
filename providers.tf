provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


######################################
# Data sources to get VPC and subnets
######################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}


provider "kubernetes" {}
data "aws_caller_identity" "current" {
}
provider "template" {
  version = "~> 2.1"
}

provider "archive" {
  version = "~> 1.2"
}
