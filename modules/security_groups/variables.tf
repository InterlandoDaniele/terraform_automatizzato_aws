variable "client_name" { type = string }
variable "vpc_id" { type = string }
variable "allowed_backend_ips" { type = list(string) }
variable "allowed_frontend_ips" { type = list(string) }
variable "allowed_fileupload_ips" { type = list(string) }
# variable "allowed_xscrapers_ips" { type = list(string) }
# variable "allowed_facebook_scraper_ips" { type = list(string) }
# variable "allowed_instagram_scraper_ips" { type = list(string) }

variable "common_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}