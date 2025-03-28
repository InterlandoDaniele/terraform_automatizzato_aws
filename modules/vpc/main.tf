resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name      = "${var.client_name}-vpc"
    Terraform = "true"
    Client    = var.client_name
  }
}

# Subnet pubbliche /27 per ALB (senza IP pubblici)
resource "aws_subnet" "elb_public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.${split(".", var.cidr_block)[1]}.${1 + count.index}.0/27"
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false  # Nessun IP pubblico
  tags = { Name = "${var.client_name}-elb_public_subnet-${count.index + 1}" }
}

# Subnet private /24 per EC2
resource "aws_subnet" "ec2_private_large" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.${split(".", var.cidr_block)[1]}.${100 + count.index}.0/24"
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.client_name}-ec2_private_large_subnet-${count.index + 1}" }
}

# Subnet private /27 per RDS
resource "aws_subnet" "rds_private_small" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.${split(".", var.cidr_block)[1]}.${103 + count.index}.0/27"
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.client_name}-rds_private_small_subnet-${count.index + 1}" }
}

# Subnet private /27 per scrapers (senza IP pubblici)
resource "aws_subnet" "scraper" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.${split(".", var.cidr_block)[1]}.${106 + count.index}.0/27"
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false  # Nessun IP pubblico
  tags = { Name = "${var.client_name}-scraper_subnet-${count.index + 1}" }
}

# VPC Peering con la VPC principale
resource "aws_vpc_peering_connection" "to_main" {
  vpc_id        = aws_vpc.this.id
  peer_vpc_id   = var.main_vpc_id
  auto_accept   = true
  tags = {
    Name = "${var.client_name}-to-main-vpc-peering"
  }
}

# Route Table unica per tutte le subnet (traffico verso il proxy tramite peering)
resource "aws_route_table" "peering" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block                = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.to_main.id
  }
  tags = { Name = "${var.client_name}-peering-rt" }
}

# Associazioni per tutte le subnet
resource "aws_route_table_association" "elb_public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.elb_public[count.index].id
  route_table_id = aws_route_table.peering.id
}

resource "aws_route_table_association" "ec2_private_large" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.ec2_private_large[count.index].id
  route_table_id = aws_route_table.peering.id
}

resource "aws_route_table_association" "rds_private_small" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.rds_private_small[count.index].id
  route_table_id = aws_route_table.peering.id
}

resource "aws_route_table_association" "scraper" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.scraper[count.index].id
  route_table_id = aws_route_table.peering.id
}
