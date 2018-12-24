variable "region" {
  description = "aws region that all the resources will be created on"
  default     = "us-west-2"
}

variable "environment" {
  description = "isolate different environment, like prod/stg."
  default     = "stg"
}

# variable "snapshot_identifier" {
#   description = "create this database from specified snapshot"
#   default     = ""
# }

variable "engine" {
  description = "the engine of rds"
  default     = ""
}

variable "engine_version" {
  description = "the version of engine"
  default     = ""
}

variable "instance_class" {
  description = "the instance class of rds"
  default     = ""
}

variable "allocated_storage" {
  description = "the storage size of rds"
  default     = 5
}
