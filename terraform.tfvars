cluster_name = "eks-cluster"
cluster_version = "1.21"
region = "eu-west-1"
vpc_cidr = "10.0.0.0/16"

argocd_version = "v2.1.6"
argocd_namespace = "argocd"

tags = {
  "Owner" = "me"
  "Project" = "eks"
}
aws_auth_users = [
    {
      userarn  = "arn:aws:iam::860634504426:user/matiasgonzalocalvo"
      username = "matiasgonzalocalvo"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::860634504426:root"
      username = "root"
      groups   = ["system:masters"]
    },
  ]


aws_auth_accounts = [
  "860634504426"
]
default_node_group_instance_type = "m5.large"


clusters = {
  dev = {
    cluster_name = "eks-cluster-dev"
    vpc_cidr = "10.0.0.0/16"
    entorno = "dev"
    branch = "develop"
    env = "dev"
    desired_capacity = 2
    max_size = 5
    min_size = 1
    volume_size = 50
    instance_type = "m5.large"
  }
  tst = {
    cluster_name = "eks-cluster-tst"
    vpc_cidr = "10.1.0.0/16"
    entorno = "tst"
    branch = "release"
    env = "tst"
    desired_capacity = 2
    max_size = 5
    min_size = 1
    volume_size = 50
    instance_type = "m5.large"
  }
  prd = {
    cluster_name = "eks-cluster-prd"
    vpc_cidr = "10.2.0.0/16"
    entorno = "prd"
    branch = "master"
    env = "prd"
    desired_capacity = 2
    max_size = 5
    min_size = 1
    volume_size = 50
    instance_type = "m5.large"
  }
}
