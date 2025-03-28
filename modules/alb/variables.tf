variable "client_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "instance_ids" {
  description = "Mappa di microservizi e ID delle istanze EC2"
  type        = map(string)
}

variable "ports" {
  description = "Mappa di microservizi e porte"
  type        = map(number)
}

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}