output "host" {
  value = "${module.rds_mysql_wordpess.this_db_instance_address}"
}

