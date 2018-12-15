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

module "wordpress" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = "${var.instance_count}"

  name                        = "ec2-pdx-b2b-p-wordpress"
  ami                         = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type               = "t2.small"
  subnet_id                   = "${element(data.terraform_remote_state.vpc.private_subnets, 0)}"
  vpc_security_group_ids      = ["${data.terraform_remote_state.sg.wordpress_sg_id}"]
  associate_public_ip_address = true
  key_name                    = "ansible.pub"
  monitoring                  = false
  user_data                   = "${file("userdata.yml")}"

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_size = 20
      volume_type = "gp2"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
    AA_SERVER_GROUP = "Wordpress"
  }
}

# resource "aws_eip" "wordpress_eip" {
#   instance = "${element(module.wordpress.id, 0)}"
#   vpc      = true
# }

resource "aws_lb" "wordpress" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.sg.wordpress_alb_sg_id}"]
  subnets            = ["${data.terraform_remote_state.vpc.public_subnets}"]

  tags {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "wordpress" {
  name     = "wordpress-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_lb_target_group_attachment" "wordpress" {
  count = "${var.instance_count}"
  target_group_arn = "${aws_lb_target_group.wordpress.arn}"
  target_id        = "${module.wordpress.id[count.index]}"
  port             = 80
}

resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = "${aws_lb.wordpress.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.wordpress.arn}"
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = "${aws_lb_listener.wordpress.arn}"

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ok"
      status_code  = "200"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/status/"]
  }
}
