output "endpoint" {
  value = "${aws_lb.wordpress.dns_name}"
}

output "private_ip" {
  value = "${module.wordpress.private_ip}"
}
