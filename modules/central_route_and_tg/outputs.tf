output "route_id" {
  description = "ID della rotta creata nella route table centrale"
  value       = aws_route.to_cliente.id
}

output "target_group_arn" {
  description = "ARN della target group creata per il cliente"
  value       = aws_lb_target_group.cliente_tg.arn
}