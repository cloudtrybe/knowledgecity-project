output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

# output "subnet_private_arns" {
#   value = [for subnet in aws_subnet.private : subnet.arn]
# }

# output "subnet_private_ids" {
#   value = [for subnet in aws_subnet.private : subnet.id]
# }

output "subnet_public_arns" {
  value = [for subnet in aws_subnet.public : subnet.arn]
}

output "subnet_public_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "igw_arn" {
  value = aws_internet_gateway.main.arn
}

output "availability_zone" {
  value = data.aws_availability_zones.available.names[0]
}