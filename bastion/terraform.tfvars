terragrunt = {
  dependencies {
    paths = [
      "../vpc",
      "../iam",
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
