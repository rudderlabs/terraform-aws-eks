terraform {
  required_version = ">= 0.12.6"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "RudderLabs"

    workspaces {
      name = "prod-saas-eks"
    }
  }
}


provider "aws" {
  version = ">= 2.28.1"
  profile = "rudder-prod"
  region  = "us-east-1"
}


module "eks-cluster" {
  source                 = "../eks-cluster"
  rudder_node_type       = "c5.2xlarge"
  vpc_single_nat_gateway = false
}
