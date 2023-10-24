region               = "us-west-2"
vpc_name             = "techvpc"
cluster_name         = "techeks"
vpc_cidr             = "172.44.0.0/16"
private_subnets_cidr = ["172.44.0.0/19", "172.44.64.0/19", "172.44.128.0/19"]
public_subnets_cidr  = ["172.44.32.0/19", "172.44.96.0/19", "172.44.160.0/19"]