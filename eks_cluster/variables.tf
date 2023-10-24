variable "cluster_name" {
  type        = string
  description = "name of cluster"
}

variable "vpc_name" {
  type        = string
  description = "name of vpc"
}

variable "region" {
  type        = string
  description = "region of vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "private subnets cidr"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "public subnets cidr"
}