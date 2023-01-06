variable "region" {
  default = "eu-central-1"
}

variable "cluster_name" {
  default = "eks-cluster-terraform"
}

variable "cluster_version" {
  default = "1.17"
}

variable "ec2_aws_key_pair_name" {
  default = "k8s-keypair"
}