locals {
  cluster_name = "${var.clustername}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "prod"
    GithubRepo  = "terraform-prod"
    GithubOrg   = "Kiq"
  }

  vpc_id = module.vpc.vpc_id

  workers_additional_policies = [aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn]

  workers_group_defaults = {
    root_volume_type = var.volume_type
  }
  
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.instance_group_type_1
      additional_userdata           = "echo foo bar"
      #asg_desired_capacity          = var.scale_group_1
      asg_max_size        = 4
      asg_min_size        = 4
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = var.instance_group_type_2
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      #asg_desired_capacity          = var.scale_group_2
      asg_max_size        = 3
      asg_min_size        = 3
    },
  ]
}

resource "kubernetes_persistent_volume" "prod" {
  metadata {
    name = "pvc"
  }
  spec {
    capacity = {
      storage = "100Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = var.volume_id
      }
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

vpc.tf

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name = var.vpc_name
  cidr = var.cidr
  azs  = data.aws_availability_zones.available.names

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
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
