data "aws_availability_zones" "available" {}

# RDS module for MySQL database
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-rds-master"

  engine            = "mysql"
  engine_version    = "8.0.35"
  family = "mysql8.0" # DB parameter group
  major_engine_version = "8.0" # DB option group
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az = true

  create_db_option_group    = false
  create_db_parameter_group = false

  db_name  = var.db_name
  username = "admin"
  port     = "3306"
  manage_master_user_password = true # Auto-generate password and store it in AWS Secrets Manager

  vpc_security_group_ids = [module.security_group.security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 0 # 0 to disable

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "${local.name}-MonitoringRole"
  create_cloudwatch_log_group = true
  create_monitoring_role = true

  tags = {
    Name = "${local.name}-rds"
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true
  # enable_nat_gateway = true 
 
  tags = {
    Name = "${local.name}-vpc"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Name = "${local.name}-vpc"
  }
}

