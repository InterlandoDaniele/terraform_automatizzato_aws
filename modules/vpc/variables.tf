variable "client_name" { type = string }
variable "cidr_block" { type = string }
variable "azs" { type = list(string) }

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}

variable "main_vpc_id" {
  description = "ID della VPC principale esistente per il peering"
  type        = string
  default     = "vpc-084642c215c19ab1c"  # Default fisso, sostituibile via tfvars
}