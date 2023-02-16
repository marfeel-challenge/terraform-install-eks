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
#desired_capacity
variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}
#max_size
variable "max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
}
#min_size
variable "min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
}
#volume_size
variable "volume_size" {
  description = "The root device volume size (in GiB)"
  type        = number
}
#env
variable "env" {
  description = "The environment"
  type        = string
}
variable "argocd_namespace" {
  description = "The namespace to deploy ArgoCD to"
  type        = string
}
variable "argocd_version" {
  description = "The version of ArgoCD to deploy"
  type        = string
  default = "stable"
}