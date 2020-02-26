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
  source = "../eks-cluster"
  # map_accounts = ["422074288268"]
  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::422074288268:role/eks-access"
  #     username = "rudder"
  #     groups   = ["system:masters"]
  #   }
  # ]
}
