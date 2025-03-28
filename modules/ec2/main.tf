resource "aws_instance" "this" {
  ami           = var.ami 
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  private_ip    = var.private_ip  # IP fisso per l'istanza
  vpc_security_group_ids = var.security_group_ids  # Lista di SG, non più `security_groups`
  user_data     = var.user_data
  key_name          = var.ssh_key_name
  tags = {
    Name = "${var.client_name}-${var.microservice}"
  }
  
  root_block_device {
    volume_size = 32
    volume_type = "gp3"
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = true
  }

}