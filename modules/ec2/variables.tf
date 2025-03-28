variable "client_name" {
  type = string
}

variable "microservice" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_type" {
  description = "Tipo di istanza EC2"
  type        = string
  default     = "t2.micro"  # Default
}


variable "ami" {
  description = "AMI per l'istanza EC2"
  type        = string 
}

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}

variable "user_data" {
  description = "Script di inizializzazione per l'istanza EC2"
  type        = string
  default     = ""  # Opzionale, vuoto se non specificato
}

variable "ssh_key_name" {
  type        = string
  description = "Nome della chiave SSH per accedere alle istanze EC2"
  default     = "terraform.pub"
}