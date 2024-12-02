data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "acm" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]

  validation_method = "DNS"

  tags = {
    Name      = "${terraform.workspace}-${var.domain_name}-acm"
    Automated = "yes"
    CreatedBy = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 resources to perform DNS auto validation
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

resource "aws_route53_record" "cname_route53_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${terraform.workspace}.${var.domain_name}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.alb_dns_name]
}