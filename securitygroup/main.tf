terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.41"
  region  = "${var.region}"
}

# Get vpc state from S3 remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "b2b-prod-ops-terraform"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion_sg"
  description = "Security group for bastion server"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "BJ office"
      cidr_blocks = "${var.office_ip}"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all traffic out"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

module "wordpress_alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "wordpress_alb_sg"
  description = "Security group for the ALB of Wordpress"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "BJ office"
      cidr_blocks = "${var.office_ip}"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all traffic out"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

module "wordpress_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "wordpress_sg"
  description = "Security group for Wordpress server"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP from the ALB of Wordpress"
      source_security_group_id = "${module.wordpress_alb_sg.this_security_group_id}"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow ssh from Bastion server"
      source_security_group_id = "${module.bastion_sg.this_security_group_id}"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all traffic out"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

module "wordpress_rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "wordpress_rds_sg"
  description = "Security group for Wordpress RDS"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MySQL from Wordpress server"
      source_security_group_id = "${module.wordpress_sg.this_security_group_id}"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all traffic out"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}
