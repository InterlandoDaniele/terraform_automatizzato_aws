module "vpc" {
  source   = "./modules/vpc"
  #for_each = toset(var.clients)

  client_name = var.business_division
  cidr_block  = "10.${var.business_id}.0.0/16"
  azs         = var.azs
  environment = var.environment
  common_tags = local.common_tags
  main_vpc_id   = var.central_vpc_id
  }

module "security_groups" {
  source   = "./modules/security_groups"
  client_name           = var.business_division
  vpc_id                = module.vpc.vpc_id
  allowed_backend_ips   = ["0.0.0.0/0"]
  allowed_frontend_ips  = ["0.0.0.0/0"]
  allowed_fileupload_ips = ["0.0.0.0/0"]
  # allowed_xscrapers_ips  = ["0.0.0.0/0"]
  # allowed_instagram_scraper_ips  = ["0.0.0.0/0"]
  # allowed_facebook_scraper_ips  = ["0.0.0.0/0"]
  environment = var.environment
  common_tags = local.common_tags

}

module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.elb_public_subnet_ids 
  client_name     = var.business_division
  security_groups = [module.security_groups.alb_sg_id]
  instance_ids    = { for k, v in module.ec2_instances_core : k => v.instance_id if contains(keys(local.microservices_core), split("-", k)[1]) }
  ports           = { for k, v in local.microservices_core : k => v.port }
  environment = var.environment
  common_tags = local.common_tags

}

# Definizione dei microservizi con IP, SG, PORT
locals {
  microservices_core = {
    "backend_green"    = { ip = 5, sg = "backend_sg_id", port = 8008 },
    "frontend_green"   = { ip = 6, sg = "frontend_sg_id", port = 80 },
    "fileupload_green" = { ip = 7, sg = "fileupload_sg_id", port = 8011 },
    "backend_blue"    = { ip = 8, sg = "backend_sg_id", port = 8008 },
    "frontend_blue"   = { ip = 9, sg = "frontend_sg_id", port = 80 },
    "fileupload_blue" = { ip = 10, sg = "fileupload_sg_id", port = 8011 },

  }


  microservices_scrapers = {
    "xcrapers"   = { ip = 14, sg = "scrapers_sg_id", port = 8012 },
    "instagram_scraper"   = { ip = 15, sg = "instagram_scraper_sg_id", port = 8013 },
    "facebook_scraper"   = { ip = 16, sg = "facebook_scraper_sg_id", port = 8014 }

  }

  # Nuova mappa per combinare microservizi e AZ
  microservices_core_azs = {
    for pair in setproduct(keys(local.microservices_core), var.azs) : 
      "${pair[0]}-${pair[1]}" => {
        microservice = pair[0]
        az           = pair[1]
        ip_offset    = local.microservices_core[pair[0]].ip
        sg           = local.microservices_core[pair[0]].sg
        port         = local.microservices_core[pair[0]].port
      }
  }

  microservices_scrapers_azs = {
    for pair in setproduct(keys(local.microservices_scrapers), var.azs) : 
      "${pair[0]}-${pair[1]}" => {
        microservice = pair[0]
        az           = pair[1]
        ip_offset    = local.microservices_scrapers[pair[0]].ip
        sg           = local.microservices_scrapers[pair[0]].sg
        port         = local.microservices_scrapers[pair[0]].port
      }
  }
}


module "ec2_instances_core" {
  source   = "./modules/ec2"
  for_each = local.microservices_core_azs

  client_name   = var.business_division
  microservice  = each.value.microservice
  subnet_id     = module.vpc.ec2_private_large_subnet_ids[index(var.azs, each.value.az)]  # Seleziona subnet per AZ
  private_ip    = "10.${var.business_id}.${100 + index(var.azs, each.value.az)}.${each.value.ip_offset}"  # IP dinamico per AZ
  security_group_ids = [
    module.security_groups[each.value.sg],
    module.security_groups.ec2-rds_sg_id,
    module.security_groups.ssh_sg_id,
    module.security_groups.uscita_sg_id
  ]
  instance_type = lookup(lookup(var.ec2_instance_types, each.value.microservice, {}), "instance_type", "t2.micro")
  ami           = lookup(lookup(var.ec2_amis, each.value.microservice, {}), "ami", data.aws_ami.amzlinux2.id)
  ssh_key_name      = var.ssh_key_name
  environment   = var.environment
  common_tags   = local.common_tags
  user_data     = <<-EOF
#!/bin/bash
echo "http_proxy=http://proxyuser:prova_123_test_456@172.31.111.246:3128" >> /etc/environment
echo "https_proxy=http://proxyuser:prova_123_test_456@172.31.111.246:3128" >> /etc/environment
echo "no_proxy=localhost,127.0.0.1,10.${var.business_id}.0.0/16,172.31.0.0/16" >> /etc/environment
EOF
}

module "ec2_instances_scrapers" {
  source   = "./modules/ec2"
  for_each = local.microservices_scrapers_azs

  client_name   = var.business_division
  microservice  = each.value.microservice
  subnet_id     = module.vpc.scraper_subnet_ids[index(var.azs, each.value.az)]  # Seleziona subnet per AZ
  private_ip    = "10.${var.business_id}.${100 + index(var.azs, each.value.az) + 6}.${each.value.ip_offset}"  # IP dinamico per AZ
  security_group_ids = [
    module.security_groups.ec2-rds_sg_id,
    module.security_groups.ssh_sg_id,
    module.security_groups.uscita_sg_id,
    module.security_groups.scrapers_sg_id
  ]
  instance_type = lookup(lookup(var.ec2_instance_types, each.value.microservice, {}), "instance_type", "t2.micro")
  ami           = lookup(lookup(var.ec2_amis, each.value.microservice, {}), "ami", data.aws_ami.amzlinux2.id)
  ssh_key_name      = var.ssh_key_name
  environment   = var.environment
  common_tags   = local.common_tags
  user_data     = <<-EOF
#!/bin/bash
echo "http_proxy=http://proxyuser:prova_123_test_456@172.31.111.246:3128" >> /etc/environment
echo "https_proxy=http://proxyuser:prova_123_test_456@172.31.111.246:3128" >> /etc/environment
echo "no_proxy=localhost,127.0.0.1,10.${var.business_id}.0.0/16,172.31.0.0/16" >> /etc/environment
EOF
}
#                         port                 = local.microservices[each.value.microservice].port AGGIUNTA PORTA AL MICROSERVIZIO

/* module "iam" {
  source   = "./modules/iam"
  for_each = toset(var.clients)

  client_name = each.value
}

module "autoscaling" {
  source   = "./modules/autoscaling"
  for_each = { for pair in setproduct(var.clients, var.microservices) : "${pair[0]}-${pair[1]}" => { client = pair[0], microservice = pair[1] } }

  client_name          = each.value.client
  microservice         = each.value.microservice
  private_subnets      = module.vpc[each.value.client].private_subnets
  security_groups      = [module.security_groups[each.value.client].ec2_sg_id]
  alb_target_group_arn = module.alb[each.value.client].target_group_arn
  instance_profile_name = module.iam[each.value.client].instance_profile_name
} */

module "rds" {
  source      = "./modules/rds"
  client_name           = var.business_division
  availability_zones   = var.azs
  private_subnet_ids    = module.vpc.rds_private_small_subnet_ids  # Subnet private /27
  rds_ec2_sg_id         = module.security_groups.rds-ec2_sg_id
  rds_lambda_sg_id      = module.security_groups.rds-lambda_sg_id
  rds_db_analytics_sg_id = [
    module.security_groups.rds-db-analytics_sg_id,
    module.security_groups.uscita_sg_id
    ]
    instance_class = lookup(var.rds_instance_classes, var.business_division, "db.t3.medium")
    environment           = var.environment
    common_tags = local.common_tags

}

module "s3" {
  source      = "./modules/s3"
  client_name = var.business_division
  common_tags = {
    Terraform = "true"
    Client    = var.business_division
    Environment           = var.environment
    Version     = var.version_release 
  }
  environment = var.environment
}

# Modulo per gestire route table e target group nella VPC centrale
module "central_route_and_tg" {
  source                = "./modules/central_route_and_tg"
  central_route_table_id = var.central_route_table_id
  central_vpc_id        = var.central_vpc_id
  cliente_cidr          = module.vpc.vpc_cidr_block
  peering_id            = module.vpc.peering_id
  business_division     = var.business_division
  business_id           = var.business_id
  proxy_instance_id     = var.proxy_instance_id
  proxy_port            = var.proxy_port
}


/* module "route53" {
  source   = "./modules/route53"
  for_each = toset(var.clients)

  client_name   = each.value
  domain_name   = var.domain_name  # Es. "example.com"
  alb_dns_name  = module.alb[each.value].alb_dns_name
  alb_zone_id   = module.alb[each.value].alb_zone_id  # Aggiungi questo output al modulo ALB
}
 */