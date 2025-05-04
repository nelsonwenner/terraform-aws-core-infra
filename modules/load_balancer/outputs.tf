output "alb_arn" {
  value = aws_lb.app.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "route53_zone_id" {
  value = var.route53_zone_id
}

output "container_port" {
  value = var.container_port
}
