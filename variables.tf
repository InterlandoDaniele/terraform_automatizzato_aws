###############################################################################
# variables.tf per il root module
# Copre tutte le variabili usate in main.tf e nei moduli ec2/rds/alb
###############################################################################

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-1"
}
# variable "common_tags" {
#   type = map(string)
# }

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

# Business Division
variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
}

variable "business_id" {
  description = "Business Division ID in the large organization this Infrastructure belongs"
  type        = number
}

# Versione da rilasciare
variable "version_release" {
  description = "Descrive la versione dell'infrastruttura (intero)"
  type        = string
}

# SSH pub name
variable "ssh_key_name" {
  description = "Il nome della chiave SSH per accedere alle istanze EC2"
  type        = string
  default     = "terraform.pub"
}

# (Opzionale) SSH pub keypath
variable "ssh_key_path" {
  description = "Il percorso del file della chiave SSH pubblica"
  type        = string
  default     = "./public_keys/terraform.pub"
}


# Definizione delle variabili globali usate nell'infrastruttura
/* variable "region" {
  description = "Regione AWS dove deployare l'infrastruttura"
  type        = string
  default     = "eu-west-1"
}
 */
/* variable "clients" {
  description = "Lista dei clienti per cui generare l'infrastruttura"
  type        = list(string)
}
 */
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]  # 3 AZ
}

variable "microservices" {
  description = "Lista dei microservizi da deployare per ogni cliente"
  type        = list(string)
  default     = ["frontend", "backend", "fileupload", "xscrapers", "instagram_scraper", "facebook_scraper"]
}

variable "domain_name" {
  description = "nome dominio"
  type        = string
  default     = "example.com"
}

variable "public_subnets" {
  description = "nome subnet"
  type        = list(string)
  default     = []
}

variable "terraform_version" {
  description = "Versione minima di Terraform richiesta"
  type        = string
  default     = ">= 1.6"
}

variable "aws_provider_version" {
  description = "Versione del provider AWS"
  type        = string
  default     = ">= 5.0"
}

variable "null_provider_version" {
  description = "Versione del provider null"
  type        = string
  default     = "~> 3.0"
}

variable "local_provider_version" {
  description = "Versione del provider local"
  type        = string
  default     = "~> 2.0"
}

variable "random_provider_version" {
  description = "Versione del provider random"
  type        = string
  default     = "~> 3.0"
}


/* variable "s3_backend_bucket" {
  description = "Nome del bucket S3 per il backend Terraform"
  type        = string
} */

variable "s3_backend_key" {
  description = "Chiave del file di stato nel bucket S3"
  type        = string
  default     = "state/terraform.tfstate"
}
/* 
variable "s3_backend_region" {
  description = "Regione del bucket S3 per il backend"
  type        = string
  default     = "eu-west-1"
} */
variable "ec2_instance_types" {
  description = "Tipi di istanze EC2 per cliente e microservizio"
  type        = map(map(string))
  default     = {}
}

variable "rds_instance_classes" {
  description = "Classi di istanze RDS per cliente"
  type        = map(string)
  default     = {}
}

variable "ec2_amis" {
 description = "AMI personalizzate per cliente e microservizio"
 type        = map(map(string))
 default     = {}
}
/* 
variable "vpc_id" {
  description = "ID della VPC"
  type        = string
}

variable "private_subnets_id" {
  description = "ID della subnet privata"
  type        = string
} */
variable "tfstate_name" {
  description = "Nome del file di stato Terraform"
  type        = string
}

variable "central_vpc_id" {
  description = "ID della VPC centrale esistente"
  type        = string
  default     = "vpc-xxxxxxxxxxxxxxxx"  # Dai tuoi dati precedenti
}

variable "central_route_table_id" {
  description = "ID della route table della VPC centrale"
  type        = string
  default     = "rtb-xxxxxxxxxxxxxxxx"  # rtb associata a proxy subnet
}

variable "proxy_instance_id" {
  description = "ID dell'istanza EC2 del proxy nella VPC centrale"
  type        = string
  default     = "i-xxxxxxxxxxxxxxxxxxxxx"  # id bastion
}

variable "proxy_port" {
  description = "Porta del proxy nella VPC centrale"
  type        = string
  default     = "3128"  # (Squid)

}

