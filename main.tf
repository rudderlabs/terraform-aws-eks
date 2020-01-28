terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = var.cluster_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"

  name                 = "rudder-vpc"
  cidr                 = var.vpc_cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 3), cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 4), cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 5)]
  public_subnets       = [cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 0), cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 1), cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, 2)]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = local.cluster_name
  subnets      = module.vpc.public_subnets

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = var.rudder_disk_size_gb
  }

  node_groups = {
    rudder-default = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = var.rudder_node_type
    }
  }

  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 7

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

data "template_file" "aws_yml" {
  count    = true ? 1 : 0
  template = file("${path.module}/templates/aws.yml.tpl")

  vars = {
    aws_region   = var.region
    vpc_id       = module.vpc.vpc_id
    cluster_name = local.cluster_name
  }
}

resource "local_file" "aws_yml" {
  count    = true ? 1 : 0
  content  = data.template_file.aws_yml[0].rendered
  filename = "aws.yml"
}
