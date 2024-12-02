data "vault_kv_secret_v2" "db_credentials" {
  mount = "kv"
  name  = "db"
}

output "db_username" {
  value     = data.vault_kv_secret_v2.db_credentials.data["username"]
  sensitive = true
}

output "db_password" {
  value     = data.vault_kv_secret_v2.db_credentials.data["password"]
  sensitive = true
}


#######################################################################
#                                 VPC                                 #
#######################################################################
module "vpc" {
  source   = "./modules/vpc"
  az_count = var.az_count
  vpc_cidr = var.vpc_cidr
}

#######################################################################
#                                 ECR                                 #
#######################################################################
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  force_delete = var.force_delete
}

#######################################################################
#                          cert manager                               #
#######################################################################
module "cert_manager" {
  source       = "./modules/acm"
  domain_name  = var.domain_name
  alb_dns_name = module.lb.alb_dns_name
}

#######################################################################
#                               mysql                                 #
#######################################################################
module "mysql" {
  source              = "./modules/mysql"
  availability_zone   = module.vpc.availability_zone
  vpc_id              = module.vpc.vpc_id
  publicly_accessible = var.publicly_accessible
  port                = var.port
  deletion_protection = var.deletion_protection
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_password         = data.vault_kv_secret_v2.db_credentials.data["password"]
  db_username         = data.vault_kv_secret_v2.db_credentials.data["username"]
  engine_version      = var.engine_version
  subnet_ids          = module.vpc.subnet_public_ids
  multi_az            = var.multi_az

  depends_on = [module.vpc]
}

#######################################################################
#                               lb                                    #
#######################################################################
module "lb" {
  source          = "./modules/lb"
  subnet_ids      = module.vpc.subnet_public_ids
  vpc_id          = module.vpc.vpc_id
  certificate_arn = module.cert_manager.certificate_arn

  depends_on = [module.vpc]
}

#######################################################################
#                               ecs                                   #
#######################################################################
module "ecs" {
  source = "./modules/ecs"
  services = {
    "knowledgecity-api-service" = {
      service_name = "knowledgecity-api-service"
      image        = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/${environment}-api:latest"
      port         = 3000
      cpu          = 256
      memory       = 512
      environment = [
        {
          "name" : "DB_USERNAME",
          "value" : "${data.vault_kv_secret_v2.db_credentials.data["username"]}"
        },
        {
          "name" : "DB_PORT",
          "value" : "8090"
        },
        {
          "name" : "DB_HOST",
          "value" : "${environment}-db.cy4m9otgjtzc.us-east-1.rds.amazonaws.com"
        },
        {
          "name" : "DB_NAME",
          "value" : "knowledgecity"
        },
        {
          "name" : "DB_PASSWORD",
          "value" : "${data.vault_kv_secret_v2.db_credentials.data["password"]}"
        },
        {
          "name" : "NODE_OPTIONS",
          "value" : "--openssl-legacy-provider"
        }
      ]
      desired_count          = 1
      assign_public_ip       = true
      health_check_path      = "/api/health"
      path_patterns          = ["/api/*"]
      max_capacity           = 5
      min_capacity           = 1
      scale_out_target_value = 75.0
      scale_in_target_value  = 25.0
    }
  }
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.subnet_public_ids
  alb_security_group_id      = module.lb.alb_security_groups_id
  alb_listener_arn           = module.lb.https
  enable_service_autoscaling = false

  depends_on = [module.lb, module.vpc, module.mysql]
}


#######################################################################
#                        aws_s3_cloudfront                            #
#######################################################################
module "cloudfront_distribution" {
  source = "./modules/cloudfront_s3"

  frontends = [
    {
      name = "react"
      bucket_name = "frontend-react-app-bucket"
    },
    {
      name = "svelte"
      bucket_name = "frontend-svelte-app-bucket"
    }
  ]
}


#######################################################################
#                        ec2_clickhouse                               #
#######################################################################
module "ec2_clickhouse" {
  source        = "./modules/ec2_clickhouse"
  environment   = "${environment}"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.public_subnet_ids
  ami_id        = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
  key_name      = "knowledgecity-ssh-key"
}