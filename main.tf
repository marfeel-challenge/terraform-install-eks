//Fix and mejore code in this file

###############################################
# EKS Module                                  #
###############################################
module "create_cluster_dev" {
  source = "./eks"
  
  cluster_name = "${var.clusters.dev.cluster_name}"
  cluster_version = var.cluster_version
  region = var.region
  vpc_cidr = "${var.clusters.dev.vpc_cidr}"
  tags = var.tags
  aws_auth_users = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts
  default_node_group_instance_type = "${var.clusters.dev.instance_type}"
  desired_capacity = "${var.clusters.dev.desired_capacity}"
  max_size = "${var.clusters.dev.max_size}"
  min_size = "${var.clusters.dev.min_size}"
  volume_size = "${var.clusters.dev.volume_size}"
  env = "${var.clusters.dev.env}"
  argocd_namespace = "${var.argocd_namespace}"
  argocd_version = "${var.argocd_version}"
}

module "create_cluster_tst" {
  source = "./eks"
  
  cluster_name = "${var.clusters.tst.cluster_name}"
  cluster_version = var.cluster_version
  region = var.region
  vpc_cidr = "${var.clusters.tst.vpc_cidr}"
  tags = var.tags
  aws_auth_users = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts
  default_node_group_instance_type = "${var.clusters.tst.instance_type}"
  desired_capacity = "${var.clusters.tst.desired_capacity}"
  max_size = "${var.clusters.tst.max_size}"
  min_size = "${var.clusters.tst.min_size}"
  volume_size = "${var.clusters.tst.volume_size}"
  env = "${var.clusters.tst.env}"
  argocd_namespace = "${var.argocd_namespace}"
  argocd_version = "${var.argocd_version}"
}

module "create_cluster_prd" {
  source = "./eks"
  
  cluster_name = "${var.clusters.prd.cluster_name}"
  cluster_version = var.cluster_version
  region = var.region
  vpc_cidr = "${var.clusters.prd.vpc_cidr}"
  tags = var.tags
  aws_auth_users = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts
  default_node_group_instance_type = "${var.clusters.prd.instance_type}"
  desired_capacity = "${var.clusters.prd.desired_capacity}"
  max_size = "${var.clusters.prd.max_size}"
  min_size = "${var.clusters.prd.min_size}"
  volume_size = "${var.clusters.prd.volume_size}"
  env = "${var.clusters.prd.env}"
  argocd_namespace = "${var.argocd_namespace}"
  argocd_version = "${var.argocd_version}"
}