# Recupero del segreto da Secrets Manager
data "aws_secretsmanager_secret" "rds" {
  name = "rds-cluster-credentials-${var.client_name}-001"
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

# Decodifica del segreto
locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)
}

# Creazione del subnet group per RDS
resource "aws_db_subnet_group" "this" {
  name       = "${var.client_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids  
  tags = {
    Name = "${var.client_name}-rds-subnet-group"
  }
}

# Creazione del cluster Aurora PostgreSQL
resource "aws_rds_cluster" "aurora_postgres" {
  cluster_identifier      = "${var.client_name}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "13.12"
  master_username         = local.rds_credentials["username"]
  master_password         = local.rds_credentials["password"]
  database_name           = local.rds_credentials["database"]
  backup_retention_period = 7
  preferred_backup_window = "02:00-06:00"
  availability_zones      = [var.availability_zones[0]]  #solo 1 AZ
  storage_encrypted       = true
  skip_final_snapshot     = true
  deletion_protection     = false
  vpc_security_group_ids  = flatten([
    var.rds_ec2_sg_id,         # Stringa singola
    var.rds_lambda_sg_id,      # Stringa singola
    var.rds_db_analytics_sg_id # Lista di stringhe
  ])
  db_subnet_group_name    = aws_db_subnet_group.this.name

  tags = {
    Name      = "${var.client_name}-aurora-postgres"
    Client    = var.client_name
    Terraform = "true"
  }
}
# Creazione di un'istanza nel cluster
resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
  count              = 1
  identifier         = "${var.client_name}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_postgres.id
  instance_class     = var.instance_class
  engine             = "aurora-postgresql"
  publicly_accessible = false
  availability_zone  = var.availability_zones[0]  # Corretto: singolare, stringa
  apply_immediately  = true
  tags = {
    Name      = "${var.client_name}-aurora-instance-${count.index + 1}"
    Client    = var.client_name
    Terraform = "true"
  }
}
  #lifecycle { prevent_destroy = true }
