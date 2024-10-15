provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source               = "./vpc"
  cidr_block           = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  tags = {
    Name = "architecture-test"
  }
}

module "alb" {
  source            = "./loadbalancer"
  alb_name          = "architecture-test-alb"
  security_groups   = [module.security_groups.alb_sg_id]
  subnets           = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  target_group_name = "architecture-test-tg"
  port              = 80
}

module "security_groups" {
  source       = "./security-groups"
  vpc_id       = module.vpc.vpc_id
  service_port = 8080
  tags = {
    Name = "architecture-test-sg"
  }
}

module "iam_roles" {
  source = "./iam-roles"
}

module "ecs_service_backend" {
  source             = "./ecs-service"
  cluster_name       = "architecture-ecs-cluster"
  family             = "backend-task-family"
  container_name     = "backend-container"
  container_image    = "767398132018.dkr.ecr.us-east-1.amazonaws.com/mohammedsayed/architecture-test:main-app"
  container_port     = 8080
  cpu                = "1024"
  memory             = "2048"
  execution_role_arn = module.iam_roles.execution_role_arn
  task_role_arn      = module.iam_roles.task_role_arn
  subnets            = module.vpc.private_subnet_ids
  security_groups    = [module.security_groups.ecs_service_sg_id]
  target_group_arn   = module.alb.target_group_arn
  desired_count      = 2

  service_name = "backend-service"
  container_definitions = jsonencode([
    {
      name      = "backend-container"
      image     = "767398132018.dkr.ecr.us-east-1.amazonaws.com/backend"
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
    }
  ])
}


module "ecs_service_frontend" {
  source             = "./ecs-service"
  cluster_name       = "architecture-ecs-cluster"
  family             = "frontend-task-family"
  container_name     = "frontend-container"
  container_image    = "767398132018.dkr.ecr.us-east-1.amazonaws.com/mohammedsayed/architecture-test:frontend"
  container_port     = 80
  cpu                = "1024"
  memory             = "2048"
  execution_role_arn = module.iam_roles.execution_role_arn
  task_role_arn      = module.iam_roles.task_role_arn
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [module.security_groups.ecs_service_sg_id]
  target_group_arn   = module.alb.target_group_arn
  desired_count      = 2

  service_name = "frontend-service" 
  container_definitions = jsonencode([{
    name      = "frontend-container"
    image     = "767398132018.dkr.ecr.us-east-1.amazonaws.com/frontend"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}


module "ecs_service_auth" {
  source             = "./ecs-service"
  cluster_name       = "architecture-ecs-cluster"
  family             = "auth-task-family"
  container_name     = "auth-container"
  container_image    = "767398132018.dkr.ecr.us-east-1.amazonaws.com/mohammedsayed/architecture-test:auth-service"
  container_port     = 8080
  cpu                = "1024"
  memory             = "2048"
  execution_role_arn = module.iam_roles.execution_role_arn
  task_role_arn      = module.iam_roles.task_role_arn
  subnets            = module.vpc.private_subnet_ids
  security_groups    = [module.security_groups.ecs_service_sg_id]
  target_group_arn   = module.alb.target_group_arn
  desired_count      = 2


  service_name = "auth-service"
  container_definitions = jsonencode([{
    name      = "auth-container"
    image     = "767398132018.dkr.ecr.us-east-1.amazonaws.com/auth"
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
  }])
}
