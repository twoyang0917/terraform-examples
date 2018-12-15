terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.41"
  region  = "${var.region}"
}

resource "aws_eip" "nat" {
  count = 2

  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dr"
  cidr = "10.114.0.0/16"

  azs              = ["${var.region}a", "${var.region}b"]
  private_subnets  = ["10.114.0.0/20", "10.114.16.0/20"]
  public_subnets   = ["10.114.101.0/24", "10.114.102.0/24"]
  database_subnets = ["10.114.201.0/24", "10.114.202.0/24"]

  create_database_subnet_group = false

  enable_nat_gateway  = true
  single_nat_gateway  = false
  one_nat_gateway_per_az = true
  reuse_nat_ips       = true
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]

  enable_s3_endpoint = true

  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}
