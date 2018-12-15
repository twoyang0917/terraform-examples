output "bastion_sg_id" {
  value = "${module.bastion_sg.this_security_group_id}"
}

output "wordpress_alb_sg_id" {
  value = "${module.wordpress_alb_sg.this_security_group_id}"
}

output "wordpress_sg_id" {
  value = "${module.wordpress_sg.this_security_group_id}"
}

output "wordpress_rds_sg_id" {
  value = "${module.wordpress_rds_sg.this_security_group_id}"
}