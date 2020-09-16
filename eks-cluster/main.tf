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
  azs_sliced   = slice(data.aws_availability_zones.available.names, 0, var.rudder_num_availability_zones == -1 || var.rudder_num_availability_zones > length(data.aws_availability_zones.available.names) ? length(data.aws_availability_zones.available.names) : var.rudder_num_availability_zones)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"

  name = "rudder-saas-vpc"
  cidr = var.vpc_cidr_block
  azs  = local.azs_sliced

  private_subnets = [
    for i in range(length(local.azs_sliced)) :
    cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, length(local.azs_sliced) + i)
  ]
  public_subnets = [
    for i in range(length(local.azs_sliced)) :
    cidrsubnet(var.vpc_cidr_block, var.vpc_cidr_subnetwork_width_delta, i)
  ]
  enable_nat_gateway   = true
  single_nat_gateway   = var.vpc_single_nat_gateway
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
  subnets      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = var.rudder_disk_size_gb

    desired_capacity = 1
    max_capacity     = 20
    min_capacity     = 1

  }

  node_groups = {
    for i in range(length(local.azs_sliced)) :
    format("rudder-%s", element(local.azs_sliced, i)) => {
      subnets       = [element(module.vpc.private_subnets, i)]
      instance_type = element(var.rudder_node_type_list, i)
    }
  }

  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 400

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

data "template_file" "aws_yml" {
  template = file("${path.module}/templates/aws.yml.tpl")

  vars = {
    aws_region   = var.region
    vpc_id       = module.vpc.vpc_id
    cluster_name = local.cluster_name
  }
}

resource "local_file" "aws_yml" {
  content  = data.template_file.aws_yml.rendered
  filename = "aws.yml"
}
