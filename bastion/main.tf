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

# Get iam state from s3 remote state
data "terraform_remote_state" "iam" {
  backend = "s3"

  config {
    bucket = "b2b-prod-ops-terraform"
    key    = "iam/terraform.tfstate"
    region = "${var.region}"
  }
}

# Get security group state from s3 remote state
data "terraform_remote_state" "sg" {
  backend = "s3"

  config {
    bucket = "b2b-prod-ops-terraform"
    key    = "securitygroup/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_ami" "ubuntu_xenial" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu Official
}

module "bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name                        = "ec2-pdx-b2b-p-ops-1"
  ami                         = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type               = "t2.small"
  subnet_id                   = "${element(data.terraform_remote_state.vpc.public_subnets, 0)}"
  vpc_security_group_ids      = ["${data.terraform_remote_state.sg.bastion_sg_id}"]
  iam_instance_profile        = "${data.terraform_remote_state.iam.bastion_profile_name}"
  associate_public_ip_address = true
  key_name                    = "ansible.pub"
  monitoring                  = false
  user_data                   = "${file("userdata.yml")}"

  root_block_device = [
    {
      volume_size = 20
      volume_type = "gp2"
    },
  ]

  tags = {
    Terraform       = "true"
    Environment     = "${var.environment}"
    AA_SERVER_GROUP = "Bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = "${element(module.bastion.id, 0)}"
  vpc      = true
}

# Extra ebs volume
# resource "aws_ebs_volume" "this" {
#   availability_zone = "${module.bastion.availability_zone[0]}"
#   size              = 10
#   type = "gp2"
# }


# resource "aws_volume_attachment" "this_ec2" {
#   device_name = "/dev/sdf"
#   volume_id   = "${aws_ebs_volume.this.id}"
#   instance_id = "${module.bastion.id[0]}"
# }

