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
    key = "vpc/terraform.tfstate"
    region  = "${var.region}"
  }
}

# Get securitygroup state from S3 remote state
data "terraform_remote_state" "sg" {
  backend = "s3"
  config {
    bucket = "b2b-prod-ops-terraform"
    key = "securitygroup/terraform.tfstate"
    region  = "${var.region}"
  }
}

# Get parameters of this rds from parameter store
data "aws_ssm_parameter" "dbport" {
  name = "/rds/wordpress/port"
}

data "aws_ssm_parameter" "dbname" {
  name = "/rds/wordpress/dbname"
}

data "aws_ssm_parameter" "dbuser" {
  name = "/rds/wordpress/master_username"
}

data "aws_ssm_parameter" "dbpassword" {
  name = "/rds/wordpress/master_password",
  with_decryption = true
}

module "rds_mysql_wordpess" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-mysql-wordpess"

  snapshot_identifier = "${var.snapshot_identifier}"

  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"

  port     = "${data.aws_ssm_parameter.dbport.value}"
  name     = "${data.aws_ssm_parameter.dbname.value}"
  username = "${data.aws_ssm_parameter.dbuser.value}"
  password = "${data.aws_ssm_parameter.dbpassword.value}"


  vpc_security_group_ids = ["${data.terraform_remote_state.sg.wordpress_rds_sg_id}"]

  maintenance_window = "Tue:09:50-Tue:10:20"
  backup_window      = "05:46-06:16"

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }

  # DB subnet group
  subnet_ids = "${data.terraform_remote_state.vpc.database_subnets}"

  create_db_parameter_group = false
  create_db_option_group = false

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "final-rds-mysql-wordpress"

  # Database Deletion Protection
  deletion_protection = false
}

# put endpoint of this rds into parameter store
resource "aws_ssm_parameter" "rds_wordpress_host" {
  name        = "/rds/wordpress/host"
  description = "the endpoint of wordpress rds"
  type        = "String"
  value       = "${module.rds_mysql_wordpess.this_db_instance_address}"

  tags {
    Environment = "${var.environment}"
  }
}
