Versions:
- Terraform: v0.14.2,v1.1.3 
- eks module: 18.0.4
- vpc module: 3.11.3
- helm provider: v2.4.1 
- aws provider: v3.71.0
- kubernetes provider: v2.7.1

Create S3 bucket: 
- name: "my-bucket-exercise"
- region: eu-west-3

Set variables:
- env_prefix = "dev"
- k8s_version = "1.21"
- cluster_name = "my-cluster"
- region = "eu-west-3"

To execute the TF script:
    `terraform init`
    `terraform apply -var-file="dev.tfvars"`