# Route nella route table centrale per il cliente
resource "aws_route" "to_cliente" {
  route_table_id            = var.central_route_table_id
  destination_cidr_block    = var.cliente_cidr
  vpc_peering_connection_id = var.peering_id
}

# Target Group per il cliente
resource "aws_lb_target_group" "cliente_tg" {
  name        = "tg-${var.business_division}-${var.business_id}"
  port        = var.proxy_port
  protocol    = "HTTP"  # Squid http
  vpc_id      = var.central_vpc_id
  target_type = "instance"

  health_check {
    path                = "/"  # endpoint proxy
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Associa il proxy alla Target Group
resource "aws_lb_target_group_attachment" "proxy_attachment" {
  target_group_arn = aws_lb_target_group.cliente_tg.arn
  target_id        = var.proxy_instance_id
  port             = var.proxy_port
}