resource "aws_security_group" "alb" {
  name        = "${var.client_name}-alb-sg"
  description = "Security group per ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "lambda-rds" {
  name        = "${var.client_name}-lambda-rds-sg"
  description = "Security group per lambda vs rds"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "rds-lambda" {
  name        = "${var.client_name}-rds-lambda-sg"
  description = "Security group per rds vs lambda"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda-rds.id]
  }
}

resource "aws_security_group" "ec2-rds" {
  name        = "${var.client_name}-ec2-rds-sg"
  description = "Security group per ec2 vs rds"
  vpc_id      = var.vpc_id
  egress { 
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "rds-ec2" {
  name        = "${var.client_name}-rds-ec2-sg"
  description = "Security group per rds vs ec2"
  vpc_id      = var.vpc_id
  ingress { 
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2-rds.id]
  }
}

resource "aws_security_group" "rds-db-analytics" {
  name        = "${var.client_name}-rds-db-analytics-sg"
  description = "Security group per rds db analytics"
  vpc_id      = var.vpc_id
  ingress { 
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
}

/* resource "aws_security_group" "xscraper" {
  name        = "${var.client_name}-xscraper-sg"
  description = "Security group per xscraper"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_xscrapers_ips
  }
}

resource "aws_security_group" "facebook_scraper" {
  name        = "${var.client_name}-facebook_scraper-sg"
  description = "Security group per facebook_scraper"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_facebook_scraper_ips
  }
}

resource "aws_security_group" "instagram_scraper" {
  name        = "${var.client_name}-instagram_scraper-sg"
  description = "Security group per instagram_scraper"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_instagram_scraper_ips
  }
} */


resource "aws_security_group" "backend" {
  name        = "${var.client_name}-backend-sg"
  description = "Security group per backend"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
/*   ingress { 
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.scrapers.id]
  } */
  ingress { 
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2-rds.id]
  }
  egress { 
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2-rds.id]
  }

}

resource "aws_security_group" "scrapers" {
  name        = "${var.client_name}-scrapers-sg"
  description = "Security group per scrapers"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.backend.id]
  }
}

resource "aws_security_group" "frontend" {
  name        = "${var.client_name}-frontend-sg"
  description = "Security group per frontend"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "fileupload" {
  name        = "${var.client_name}-fileupload-sg"
  description = "Security group per fileupload"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 8011
    to_port     = 8011
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "${var.client_name}-ssh-sg"
  description = "Security group per ssh"
  vpc_id      = var.vpc_id
  ingress { 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
}
resource "aws_security_group" "uscita" {
  name        = "${var.client_name}-uscita-sg"
  description = "Security group per uscita"
  vpc_id      = var.vpc_id
  egress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}