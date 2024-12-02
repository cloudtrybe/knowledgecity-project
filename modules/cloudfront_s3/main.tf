locals {
  cloudfront_origins = {
    for frontend in var.frontends : frontend.name => {
      domain_name = aws_s3_bucket[frontend.name].bucket_regional_domain_name
      origin_id   = frontend.name
      origin_path = "/"
    }
  }
}

resource "aws_s3_bucket" "frontend_buckets" {
  for_each = var.frontends

  bucket = each.value.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
  tags = {
    Name        = each.value.bucket_name
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policies" {
  for_each = var.frontends

  bucket = aws_s3_bucket.frontend_buckets[each.key].id
  policy = data.aws_iam_policy_document.cloudfront_access_policy.json
}

resource "aws_cloudfront_distribution" "distribution" {
  origin_groups {
    origin_group_id = "primary-group"

    origins {
      for origin in local.cloudfront_origins :
        domain_name = origin.domain_name
        origin_id   = origin.origin_id
        origin_path = origin.origin_path
    }
  }
  enabled = true
  viewer_certificate {
    acm_certificate_arn = module.cert_manager.certificate_arn
    ssl_support_method  = "sni-only"
  }
}