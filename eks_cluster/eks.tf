module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets //Cluster is deployed in private subnet

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  //cluster_endpoint_public_access_cidrs can be added to restrict the cidrs for public access. https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1867

  # Note: By default, the IAM Role or IAM User that was used to create the cluster, is added to the system:masters group and gets cluster-wide admin permission with cluster-admin ClusterRole. This is required when we want EKS to allow giving access to other users by adding them in a configmap aws-auth in kube-system namespace.
  manage_aws_auth_configmap = true //to manage aws-auth configmap

  eks_managed_node_group_defaults = { //Map of EKS managed node group default configurations
    create_launch_template = true
    launch_template_name   = "eks-launch-template"
    ami_type               = "BOTTLEROCKET_x86_64"
    disk_size              = 50
    instance_types         = ["t3.small", "t3.medium"]
  }
  eks_managed_node_groups = { //Map of EKS managed node group definitions to create
    nodegroup1 = {
      labels = {
        NodeGroup = "nodegroup1"
      }
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  tags = local.tags

}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns    = {}
    vpc-cni    = {}
    kube-proxy = {}
  }

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true
  tags = local.tags
}
