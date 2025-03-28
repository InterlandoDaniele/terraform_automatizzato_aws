output "cluster_id" {
  value = aws_rds_cluster.aurora_postgres.id
}

output "instance_ids" {
  value = aws_rds_cluster_instance.aurora_postgres_instance[*].id
}

output "endpoint" {
  value = aws_rds_cluster.aurora_postgres.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_postgres.reader_endpoint
}

output "aurora_postgres_cluster_endpoint" {
  value       = aws_rds_cluster.aurora_postgres.endpoint
  description = "Endpoint del cluster Aurora PostgreSQL"
}

output "aurora_postgres_instance_endpoint" {
  value       = aws_rds_cluster_instance.aurora_postgres_instance[0].endpoint
  description = "Endpoint dell'istanza Aurora PostgreSQL"
}

output "aurora_postgres_instance_id" {
  value       = aws_rds_cluster_instance.aurora_postgres_instance[0].id
  description = "ID dell'istanza Aurora PostgreSQL"
}

output "rds_instance_identifier" {
  value       = aws_rds_cluster_instance.aurora_postgres_instance[0].id
  description = "Identificatore dell'istanza RDS"
}

output "rds_instance_private_ip" {
  value       = aws_rds_cluster_instance.aurora_postgres_instance[0].endpoint
  description = "Endpoint (usato come IP privato) dell'istanza RDS"
}

# Output the secret name
/* output "rds_secret_name" {
  description = "The name of the AWS Secrets Manager entry storing the RDS credentials"
  value       = var.rds_db_secrets_name
}
 */
# Output the stored username from the secret
output "rds_username" {
  description = "The master username for the RDS instance"
  value       = local.rds_credentials["username"]
  sensitive   = true
}

# Output the stored database name from the secret
output "rds_database_name" {
  description = "The database name used in the RDS cluster"
  value       = local.rds_credentials["database"]
}

# Output the RDS cluster endpoint
output "rds_cluster_endpoint" {
  description = "The primary endpoint of the RDS cluster"
  value       = aws_rds_cluster.aurora_postgres.endpoint
}

# Output the Reader endpoint for read replicas
output "rds_reader_endpoint" {
  description = "The reader endpoint for read replicas in the RDS cluster"
  value       = aws_rds_cluster.aurora_postgres.reader_endpoint
}

# Output the RDS cluster ARN
output "rds_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the RDS cluster"
  value       = aws_rds_cluster.aurora_postgres.arn
}

# Output the RDS cluster ID
output "rds_cluster_id" {
  description = "The identifier of the RDS cluster"
  value       = aws_rds_cluster.aurora_postgres.id
}

# Output the security group ID used for the RDS cluster
/* output "rds_security_group_id" {
  description = "The security group ID assigned to the RDS cluster"
  value       = var.rds_nsg_id
}
 */

 