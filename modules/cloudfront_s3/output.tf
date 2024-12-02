output "cloudfront_domain_name" {
  value = {
    for frontend in var.frontends : frontend.name => aws_s3_bucket.frontend_buckets[frontend.name].bucket_regional_domain_name
  }
  description = "Domain name of the CloudFront distribution"
}

output "s3_bucket_arns" {
  type = map(string)
  value = {
    for frontend in var.frontends : frontend.name => aws_s3_bucket.frontend_buckets[frontend.name].arn
  }
  description = "ARN of each S3 bucket for the frontends"
}