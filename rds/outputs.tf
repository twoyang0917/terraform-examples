output "host" {
  value = "${module.rds_mysql_wordpress.this_db_instance_address}"
}

