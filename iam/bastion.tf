
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bastion_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "rds:Describe*",
      "elasticache:Describe*",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "ssm:DescribeParameters",
    ]

    resources = [
      "*",
    ]
  },

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/*",
    ]
  }
}

resource "aws_iam_policy" "bastion_policy" {
  name        = "bastion_policy"
  path        = "/terraform/"
  description = "describe tags of ec2, used by ansible dynamic inventory."
  policy      = "${data.aws_iam_policy_document.bastion_policy_doc.json}"
}

resource "aws_iam_role" "bastion" {
  name               = "bastion"
  path               = "/terraform/"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "bastion_attach" {
  name       = "bastion_attach"
  roles      = ["${aws_iam_role.bastion.name}"]
  policy_arn = "${aws_iam_policy.bastion_policy.arn}"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_profile"
  path = "/terraform/"
  role = "${aws_iam_role.bastion.name}"
}