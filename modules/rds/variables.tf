variable "client_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)  # Subnet private /27
}

variable "rds_ec2_sg_id" {
  type = string  # SG per RDS-EC2
}

variable "rds_lambda_sg_id" {
  type = string  # SG per RDS-Lambda
}

variable "rds_db_analytics_sg_id" {
  type = list(string)  # SG per RDS-DB Analytics
}

variable "instance_class" {
  description = "Classe di istanza RDS"
  type        = string
  default     = "db.t3.medium"  # Default se non specificato
}

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}
