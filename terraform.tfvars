terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"
    config {
      bucket         = "b2b-prod-ops-terraform"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "us-west-2"
      encrypt        = true
      dynamodb_table = "terraform-locks"
    }
  }
  # Configure root level variables that all resources can inherit
  terraform {
    required_version = ">= 0.11.8"
    extra_arguments "bucket" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      optional_var_files = [
          "${get_parent_tfvars_dir()}/common.tfvars"
      ]
    }
  }
}
