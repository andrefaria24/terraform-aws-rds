provider "aws" {
  region = var.region
}

provider "random" {}

data "aws_availability_zones" "available" {}

resource "random_string" "random_str" {
  length  = 6
  numeric = false
  special = false
  upper   = false
}

resource "random_integer" "random_int" {
  min = 3
  max = 3
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name                 = "${random_string.random_str.id}-${random_integer.random_int.id}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${random_string.random_str.id}-${random_integer.random_int.id}"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${random_string.random_str.id}-${random_integer.random_int.id}"
  }
}

resource "aws_security_group" "rds" {
  name   = "${random_string.random_str.id}-${random_integer.random_int.id}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "db_param_group" {
  name   = "${random_string.random_str.id}-${random_integer.random_int.id}"
  family = "mysql5.7"

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

# ephemeral "random_password" "db_password" {
#   length  = 16
#   special = false
# }

# locals {
#   # Increment db_password_version to update the DB password and store the new password in SSM.
#   db_password_version = 1
# }

resource "aws_db_instance" "db_instance" {
  identifier        = "${var.db_name}-${random_string.random_str.id}"
  instance_class    = "db.t3.micro"
  allocated_storage = 5
  apply_immediately = true
  engine            = "mysql"
  engine_version    = "5.7"
  username          = var.db_username
  password          = resource.random_password.db_password.result
  # password_wo            = ephemeral.random_password.db_password.result
  # password_wo_version    = local.db_password_version
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.db_param_group.name
  publicly_accessible    = true
  skip_final_snapshot    = true
  # storage_encrypted      = var.db_encrypted
}

resource "aws_ssm_parameter" "secret" {
  name        = "/database/${var.db_name}/password/master"
  description = "Password for RDS database."
  type        = "SecureString"
  value       = resource.random_password.db_password.result
  # value_wo         = ephemeral.random_password.db_password.result
  # value_wo_version = local.db_password_version
}