terragrunt = {
  dependencies {
    paths = ["../vpc"]
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

office_ip = "45.117.99.182/32"