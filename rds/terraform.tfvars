terragrunt = {
  dependencies {
    paths = [
      "../vpc",
      "../securitygroup"
    ]
  }
  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }

  # terraform {
  #   extra_arguments "custom_vars" {
  #     commands = [
  #       "apply",
  #       "plan",
  #       "refresh"
  #     ]

  #     arguments = [
  #       "-var-file=terraform.tfvars"
  #     ]
  #   }
  # }
}

# snapshot_identifier = "cms-rds-mysql"
engine            = "mysql"
engine_version    = "5.6.34"
instance_class    = "db.m1.large"
allocated_storage = 5