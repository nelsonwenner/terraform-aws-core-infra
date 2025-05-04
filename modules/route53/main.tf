# Optional: use an existing Route 53 Hosted Zone if use_existing_zone is true.
data "aws_route53_zone" "existing" {
  count        = var.use_existing_zone ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# Creates a new Route 53 Hosted Zone if use_existing_zone is false.
resource "aws_route53_zone" "created" {
  count = var.use_existing_zone ? 0 : 1
  name  = var.domain_name

  tags = merge(
    var.tags,
    {
      "Name" = "route53_zone-${var.env}-${var.project_name}-fargate"
    }
  )
}

# Dynamically select the correct Hosted Zone ID based on user input.
locals {
  route53_zone_id = try(
    data.aws_route53_zone.existing[0].zone_id,
    aws_route53_zone.created[0].zone_id
  )
}

# Creates Route 53 DNS records for certificate validation using dynamic lookup.
resource "aws_route53_record" "record_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name     # Record name to be created (e.g., _abc123.example.com)
      record = dvo.resource_record_value    # Value expected by ACM to prove ownership
      type   = dvo.resource_record_type     # Typically CNAME
    }
  }

  allow_overwrite = true                     # Allows re-creation if needed
  name            = each.value.name          # DNS record name
  records         = [each.value.record]      # DNS record value
  ttl             = 300                      # Low TTL for faster propagation
  type            = each.value.type          # Record type (usually CNAME)
  zone_id         = local.route53_zone_id  # Hosted Zone ID for the domain
}

# Requests a wildcard ACM certificate for a given domain, using DNS validation.
# Example: *.example.com will secure any subdomain like api.example.com or www.example.com
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name                  # Wildcard certificate
  subject_alternative_names = ["*.${var.domain_name}"] # Additional SANs can be added here
  validation_method = "DNS"                            # DNS-based domain ownership validation

  tags = merge(
    {
      "Name" = "acm_certificate-${var.env}-${var.project_name}-fargate"
    },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true  # Ensures new cert is created before old one is destroyed during updates
  }
}

# Triggers ACM validation after record creation.
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record_certificate_validation : record.fqdn]
}
