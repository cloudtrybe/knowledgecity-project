region  = "me-south-1"
environment = "prod"

account_id = ""############""

az_count = 2
vpc_cidr = "172.8.0.0/16"

######## ec2_clickhouse ############
ami_id = "ami-0abcdef1234567890"
instance_type = "t3.medium"

######## mysql ############
publicly_accessible = true
port                = 8090
deletion_protection = false
db_instance_class   = "db.t3.micro"
db_name             = "coreservice"
engine_version      = "8.0.35"
multi_az            = false

############ ecr ################
ecr_name     = "dev"
force_delete = true

############# certificate manager #############
domain_name = "knowledgecity.com"