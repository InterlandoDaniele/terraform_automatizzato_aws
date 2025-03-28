variable "client_name" {
  type        = string
  description = "Nome del cliente per identificare le risorse"
}

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}