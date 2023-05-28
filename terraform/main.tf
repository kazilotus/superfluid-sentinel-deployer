locals {
  sentinel_env = jsondecode(var.sentinel_env)
  common_tags = {
    Environment = "production"
    Name        = "superfluid-sentinel"
  }
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name                = "superfluid-sentinel"
  family_name                 = "superfluid-sentinel"
  region                      = var.aws_region
  image                       = format("%s:%s", module.ecr.repository_url, var.image_tag)
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  subnets                     = module.networking.subnet_ids
  security_group_id           = module.networking.security_group_id
  cpu                         = var.cpu
  memory                      = var.memory

  environment_variables       = local.sentinel_env

  tags = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "superfluid-sentinel"
  tags            = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  ecs_task_execution_role_name = "ecs_task_execution_role"
  tags                         = local.common_tags
}

module "networking" {
  source = "./modules/networking"
  tags   = local.common_tags
}

