locals {
  tags = {
    Project = "EKSTest"
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  create_egress_only_igw = true

  enable_nat_gateway   = true
  single_nat_gateway   = true //Should be true if you want to provision a single shared NAT Gateway across all of your private networks
  enable_dns_hostnames = true //Should be true to enable DNS hostnames in the VPC

  enable_flow_log                      = true //Whether or not to enable VPC Flow Logs
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    // AWS Cloud Controller Manager require subnets to have this tags
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" //AWS Cloud Controller Manager query a cluster's subnets to identify them. The shared value allows more than one cluster to use the subnet.
    "kubernetes.io/role/elb"                    = 1        //Cloud Controller Manager determines if a subnet is public
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" //AWS Cloud Controller Manager query a cluster's subnets to identify them. The shared value allows more than one cluster to use the subnet.
    "kubernetes.io/role/internal-elb"           = 1        //Cloud Controller Manager determines if a subnet is private
  }

  tags = local.tags
}
