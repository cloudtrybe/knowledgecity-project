output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_security_groups_id" {
  value = aws_security_group.alb.id
}

output "http" {
  value = aws_lb_listener.http.arn
}

output "https" {
  value = aws_lb_listener.https.arn
}