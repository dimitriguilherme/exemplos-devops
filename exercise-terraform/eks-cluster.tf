module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.0.4"

  cluster_name    = local.cluster_name
  cluster_version = var.k8s_version
  subnet_ids      = module.vpc.private_subnets

  tags = {
    Environment = "bootcamp"
    Terraform = "true"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    # blue = {}
    # green = {}
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.small"]
      labels = {
        Environment = var.env_prefix
      }
    }
  }

  fargate_profiles = {
    default = {
      name = "my-fargate-profile"
      selectors = [
        {
          namespace = "my-app"
        }
      ]
    }
  }
}