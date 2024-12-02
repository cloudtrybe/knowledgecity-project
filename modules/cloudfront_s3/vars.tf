variable "frontends" {
  type = list(object({
    name = string
    bucket_name = string
  }))
}

variable "cloudfront_default_cache_behavior_settings" {
  type    = map(string)
  default = {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 31536000
  }
}