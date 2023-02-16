#ClusterName
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
#ClusterVersion
variable "cluster_version" {
  description = "The EKS cluster version"
  type        = string
}
#region
variable "region" {
  description = "The AWS region"
  type        = string
}
#vpc_cidr
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
#tags
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
#aws_auth_users
variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}
#aws_auth_accounts
variable "aws_auth_accounts" {
  description = "A list of AWS account IDs to add to aws-auth configmap"
  type        = list(string)
  default     = []
}
#default_node_group instance type
variable "default_node_group_instance_type" {
  description = "The instance type to use for the default node group"
  type        = string
}


variable "clusters" {
  type = map(object({
    cluster_name = string
    vpc_cidr = string
    entorno = string
    branch = string
    env = string
    desired_capacity = number
    min_size = number
    max_size = number
    instance_type = string
    volume_size = number
  }))
}
variable "environments" {
  type = list(string)
  default = ["dev", "tst"]
}

#argocd_version
variable "argocd_version" {
  description = "The ArgoCD version"
  type        = string
}
#argocd_namespace
variable "argocd_namespace" {
  description = "The ArgoCD namespace"
  type        = string
}