terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name           = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  azs            = var.availability_zones

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  name         = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_ids[0]
  instance_type = var.instance_type

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}


