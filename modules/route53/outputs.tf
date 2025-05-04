output "acm_arn" {
  value = aws_acm_certificate.cert.arn
}

output "route53_zone_id" {
  value = local.route53_zone_id
}
