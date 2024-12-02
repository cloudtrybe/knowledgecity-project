output "alb_dns" {
  value = module.lb.alb_dns_name
}

output "alb_arn" {
  value = module.lb.alb_arn
}

output "db_endpoint" {
  value = module.mysql.db_instance_endpoint
}

output "ecs_service" {
  value = module.ecs.ecs_service_name
}

output "certificate_arn" {
  value = module.cert_manager.certificate_arn
}

output "repository_url" {
  value = module.ecr.repository_url
}

output "repository_arn" {
  value = module.ecr.repository_arn
}

output "cloudfront_domain_name" {
  value = module.cloudfront_distribution.cloudfront_domain_name
}

output "s3_bucket_names" {
  value = {
    for frontend in module.cloudfront_distribution.frontends : frontend.name => frontend.bucket_name
  }
}