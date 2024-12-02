output "clickhouse_instance_ids" {
  value = aws_instance.clickhouse[*].id
}

output "clickhouse_instance_ips" {
  value = aws_instance.clickhouse[*].public_ip
}

output "security_group_id" {
  value = aws_security_group.clickhouse.id
}
