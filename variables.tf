variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "db_username" {
  description = "RDS root username"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-2", "eu-west-1"], var.region)
    error_message = "Supported regions: us-east-1, us-east-2, us-west-2, eu-west-1"
  }
}

variable "instance_class" {
  description = "Aurora Instance Size"
  type        = string
  default     = "db.r6g.large"
  validation {
    condition     = contains(["db.r6g.large", "db.r6g.xlarge", "db.r6g.2xlarge"], var.instance_class)
    error_message = "Supported sizes: db.r6g.large, db.r6g.xlarge, db.r6g.2xlarge"
  }
}