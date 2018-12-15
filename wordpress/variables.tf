variable "region" {
  description = "aws region that all the resources will be created on"
  default     = "us-west-2"
}

variable "environment" {
  description = "isolate different environment, like prod/stg."
  default     = "stg"
}

variable "instance_count" {
  description = "isolate different environment, like prod/stg."
  default     = 1
}