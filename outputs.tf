#output "alb_urls" { value = { for k, v in module.alb : k => v.alb_dns_name } }
#output "rds_endpoints" { value = { for k, v in module.rds : k => v.rds_endpoint } }
#output "dns_names" { value = { for k, v in module.route53 : k => v.dns_name } }
#output "asg_names" { value = { for k, v in module.autoscaling : k => v.asg_name } }
#output "ami" { value = { for k, v in modules.ec2 : k => v.ami } }

output "vpc_details" {
  value = { 
      vpc_id = module.vpc.vpc_id, 
      public_subnets = module.vpc.elb_public_subnet_ids, 
      private_subnets = module.vpc.ec2_private_large_subnet_ids 
    } 
  }

output "s3_buckets" {
  value = { 
      media_ingestion = module.s3.media_ingestion_bucket_name,
      metadata_ingestion = module.s3.metadata_ingestion_bucket_name,
      alert_engines_output = module.s3.alert_engines_output_bucket_name,
      media_alerts = module.s3.media_alerts_bucket_name,
      report = module.s3.report_bucket_name,
      media_scan_result = module.s3.media_scan_result_bucket_name,
      auxiliary_media = module.s3.auxiliary_media_bucket_name
    } 
  }


output "scraper_instance_ips" {
  value = {
    for microservice in keys(local.microservices_scrapers) : 
      "${var.business_division}-${microservice}" => [
        for k, v in module.ec2_instances_scrapers : 
          v.private_ip 
          if split("-", k)[0] == microservice
      ]
  }
}

output "core_instance_ips" {
  value = {
    for microservice in keys(local.microservices_core) : 
      "${var.business_division}-${microservice}" => [
        for k, v in module.ec2_instances_core : 
          v.private_ip 
          if split("-", k)[0] == microservice
      ]
  }
}
# output "core_instance_ips" {
#   value = {
#     for k, v in module.ec2_instances_core : 
#       "${var.business_division}-${k}" => v.private_ip
#   }
# }
#ESEMPIO
# {
#   "consulthink-xcrapers": "10.2.106.14",
#   "consulthink-instagram_scraper": "10.2.106.15",
#   "consulthink-facebook_scraper": "10.2.106.16",
#   "demo-xcrapers": "10.3.106.14",
#   ...
# }

output "debug_scraper_az_mapping" {
  value = { for k, v in local.microservices_scrapers_azs : k => index(var.azs, v.az) }
}

output "debug_microservices_core_azs" {
  value = local.microservices_core_azs
}

output "debug_core_azs" {
  value = local.microservices_core_azs
}

output "debug_scraper_azs" {
  value = local.microservices_scrapers_azs
}

output "debug_core_subnets" {
  value = module.vpc.ec2_private_large_subnet_ids
}

output "debug_scraper_subnets" {
  value = module.vpc.scraper_subnet_ids
}

output "microservices_core_azs" {
  value = local.microservices_core_azs
}
