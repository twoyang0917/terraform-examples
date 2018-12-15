output "public_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

output "private_ip" {
  value = "${aws_eip.bastion_eip.private_ip}"
}
