provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"
}

module "security_groups" { 
  source = "./security_groups"
  vpc_id = module.vpc.vpc_id
  subnet_id           = module.vpc.subnet1_id
}

module "ec2" {
  source              = "./ec2"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.subnet1_id
  security_group_id   = module.security_groups.sg_id
}
