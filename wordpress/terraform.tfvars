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
}

instance_count = 2
