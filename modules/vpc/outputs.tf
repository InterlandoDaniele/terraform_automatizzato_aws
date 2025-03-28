output "vpc_id" {
  value = aws_vpc.this.id
}

output "elb_public_subnet_ids" {
  value = aws_subnet.elb_public[*].id
}

output "ec2_private_large_subnet_ids" {
  value = aws_subnet.ec2_private_large[*].id
}

output "rds_private_small_subnet_ids" {
  value = aws_subnet.rds_private_small[*].id
}

output "scraper_subnet_ids" {
  value = aws_subnet.scraper[*].id
}

output "peering_id" { value = aws_vpc_peering_connection.to_main.id }

output "vpc_cidr_block" { value = aws_vpc.this.cidr_block }


