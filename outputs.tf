output "region" {
  description = "AWS region for all resources."
  value       = var.region
}

output "rds_hostname" {
  description = "RDS instance hostname."
  value       = aws_db_instance.db_instance.address
}

output "rds_port" {
  description = "RDS instance port."
  value       = aws_db_instance.db_instance.port
}

output "rds_dbname" {
  description = "RDS instance database name."
  value       = var.db_name
}

output "rds_username" {
  description = "RDS instance root username."
  value       = aws_db_instance.db_instance.username
}

output "rds_password" {
  description = "RDS instance root password."
  value       = aws_db_instance.db_instance.password
  # value       = aws_db_instance.db_instance.password_wo
  sensitive   = true
}