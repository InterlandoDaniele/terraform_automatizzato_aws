resource "aws_lb" "this" {
  name               = "${var.client_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups  # Usa il SG passato dal main.tf
  subnets            = var.subnet_ids      # Corretto da public_small_subnet_ids
  tags = {
    Name = "${var.client_name}-alb"
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.client_name}-backend-tg"
  port     = 8008
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_lb_target_group" "frontend" {
  name     = "${var.client_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "fileupload" {
  name     = "${var.client_name}-fileupload-tg"
  port     = 8011
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8008
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# Regola per Listener Backend: /upload/* → fileupload
resource "aws_lb_listener_rule" "backend_fileupload" {
  listener_arn = aws_lb_listener.backend.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fileupload.arn
  }

  condition {
    path_pattern {
      values = ["/upload/*"]
    }
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Regola per Listener Frontend: /upload/* → fileupload
resource "aws_lb_listener_rule" "frontend_fileupload" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fileupload.arn
  }

  condition {
    path_pattern {
      values = ["/upload/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "backend" {
  for_each         = { for k, id in var.instance_ids : k => id if contains(["backend_green", "backend_blue"], split("-", k)[1]) }
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = each.value
  port             = var.ports[split("-", each.key)[1]]
}

resource "aws_lb_target_group_attachment" "frontend" {
  for_each         = { for k, id in var.instance_ids : k => id if contains(["frontend_green", "frontend_blue"], split("-", k)[1]) }
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = each.value
  port             = var.ports[split("-", each.key)[1]]
}

resource "aws_lb_target_group_attachment" "fileupload" {
  for_each         = { for k, id in var.instance_ids : k => id if contains(["fileupload_green", "fileupload_blue"], split("-", k)[1]) }
  target_group_arn = aws_lb_target_group.fileupload.arn
  target_id        = each.value
  port             = var.ports[split("-", each.key)[1]]
}