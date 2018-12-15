terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.41"
  region  = "${var.region}"
}

resource "aws_ssm_parameter" "rds_wordpress_dbname" {
  name        = "/rds/wordpress/dbname"
  description = "the database name of wordpress rds"
  type        = "String"
  value       = "wordpress"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "rds_wordpress_port" {
  name        = "/rds/wordpress/port"
  description = "the port of wordpress rds"
  type        = "String"
  value       = "3306"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "rds_wordpress_master_username" {
  name        = "/rds/wordpress/master_username"
  description = "the master username of wordpress rds"
  type        = "String"
  value       = "root"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "rds_wordpress_master_password" {
  name        = "/rds/wordpress/master_password"
  description = "the master password of wordpress rds"
  type        = "SecureString"
  value       = "wordpress"

  tags {
    Environment = "${var.environment}"
  }
}
