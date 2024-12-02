region     = "us-east-1"
account_id = "806126151129"

az_count = 2
vpc_cidr = "172.8.0.0/16"

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
domain_name = "tobialabifoundation.com"

