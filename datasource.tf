# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    #values = ["amazon/al2023-ami-*"]
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get latest AMI ID for Ubuntu 22.04 Canonical OS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# certificato mediaminer letsencrypt
# data.aws_acm_certificate.mediaminer.arn
data "aws_acm_certificate" "mediaminer" {
  domain      = "mediaminer.it"
  statuses    = ["ISSUED"]
  most_recent = true
}
