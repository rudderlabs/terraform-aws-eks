terraform {
  required_version = ">= 0.12.6"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "RudderLabs"

    workspaces {
      name = "dev-saas-eks"
    }
  }
}


provider "aws" {
  version = ">= 2.28.1"
  profile = "rudder-dev"
  region  = "us-east-1"
}


module "eks-cluster" {
  source       = "../eks-cluster"
  map_accounts = ["454531037350"]
  map_roles = [
    {
      rolearn  = "arn:aws:iam::454531037350:role/eks-access"
      username = "rudder"
      groups   = ["system:masters"]
    }
  ]
}
