provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
  
    
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  
  name            = var.cluster_name
  cluster_version = var.cluster_version
  region          = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  aws_auth_users = []
  tags = merge(
    {
      "Environment" = "dev"
      "Name"        = local.name
      "Owner"       = "me"
      "Project"     = "eks"
    },
    var.tags,

    
  )
}

################################################################################
# EKS Module
################################################################################

module "eks" {

  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  self_managed_node_group_defaults = {
    # enable discovery of autoscaling groups by cluster-autoscaler force m4.large to be used
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${local.name}" : "owned",
    }
  }

  self_managed_node_groups = {
    # Default node group - as provisioned by the module defaults
    default_node_group = {
      instance_type = var.default_node_group_instance_type
      desired_capacity = "${var.desired_capacity}"
      max_size = "${var.max_size}"
      min_size = "${var.min_size}"
        volume_size = "${var.volume_size}"
        labels = {
          environment = "${var.env}"
        }
      ami_id = data.aws_ami.eks_default.id
      /* update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      } */
      tags = {
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.name}" : "owned",
      }
    }

  }

  aws_auth_users = var.aws_auth_users

  aws_auth_accounts = var.aws_auth_accounts

  tags = local.tags

}

################################################################################
# EKS ngnix
################################################################################

 /* provider "helm" {
  kubernetes {
    //config_path = "~/.kube/config"
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }

  
}

resource "helm_release" "nginx-ingress-controller" {

  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    //name = "controller.service.annotations."ingress.kubernetes.io/external-dns-alias""
    name  = "controller.service.annotations.\"ingress.kubernetes.io/external-dns-alias\""
    value = "*.probando-helm-argo-etc.eu-west-1.elb.amazonaws.com"
  }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  depends_on = [
    module.eks
  ]
} */

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

data "aws_ami" "eks_default" {
  
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.name}/ebs"]

  tags = local.tags

}

resource "aws_iam_policy" "additional" {
  
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}



################################################################################
# Install ArgoCD
################################################################################
data "template_file" "kustomization" {
  template = file("${path.module}/kustomization.yaml.tpl")
  vars = {
    argocd_namespace = var.argocd_namespace
    argocd_version   = var.argocd_version
  }
}
resource "local_file" "kustomization_yaml" {
  content  = data.template_file.kustomization.rendered
  filename = "/tmp/argocd/kustomization.yaml"
}

resource "kubernetes_namespace" "argocd_ns" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "null_resource" "argocd_installation" {
  /* triggers = {
    always_run = "${timestamp()}"
  } */
  provisioner "local-exec" {
    command = "kustomize build /tmp/argocd/  | kubectl apply -f -"
  }
}

resource "null_resource" "expose_argocd" {
  /* triggers = {
    always_run = "${timestamp()}"
  } */
  provisioner "local-exec" {
    command = "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"
  }
  depends_on = [
    null_resource.argocd_installation
  ]
}


################################################################################
# Configure kubectl in machine
################################################################################
resource "null_resource" "login_eks" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "KUBECONFIG=\"~/.kube/config-${var.cluster_name}\" aws eks update-kubeconfig --name ${var.cluster_name}"
  }
}