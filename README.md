## Generative AI generated README.md
# AWS EKS Terraform

Terraform project for provisioning an AWS Elastic Kubernetes Service (EKS) cluster with customizable networking, security groups, and public/private cluster access.

This repository helps you quickly bootstrap a production-ready Kubernetes cluster on AWS using Terraform.

---

## Features

- Create AWS EKS Cluster
- Custom VPC and subnet configuration
- Public or private cluster endpoint access
- Configurable worker nodes
- Security group management
- Infrastructure as Code (IaC)
- Easy Terraform workflow

---

## Project Structure

```bash
.
├── provider.tf
├── vpc.tf
├── eks.tf
├── sg.tf
├── variables.tf
├── outputs.tf
└── conf/
    └── input.tfvars
```

---

## Prerequisites

Before starting, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- AWS Account with sufficient permissions

---

## Configure AWS Credentials

```bash
aws configure
```

Provide:

- AWS Access Key ID
- AWS Secret Access Key
- Default Region
- Output Format

---

## Clone Repository

```bash
git clone https://github.com/guxkung/eks-terraform.git
cd eks-terraform
```

---

## Configuration

Edit:

```bash
conf/input.tfvars
```

Example:

```hcl
aws_region     = "ap-southeast-1"
cluster_name   = "demo-eks"
vpc_cidr       = "10.0.0.0/16"

private_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

public_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24"
]
```

Adjust values according to your environment.

---

# Deploy EKS Cluster

## Initialize Terraform

```bash
terraform init
```

---

## Review Execution Plan

```bash
terraform plan \
  -var-file=conf/input.tfvars \
  -out eks.plan
```

---

## Apply Infrastructure

```bash
terraform apply eks.plan
```

Terraform will provision:

- VPC
- Subnets
- Internet/NAT Gateways
- Security Groups
- EKS Cluster
- Worker Nodes

---

# Access Kubernetes Cluster

After deployment:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name demo-eks
```

Verify connection:

```bash
kubectl get nodes
```

---

# Public vs Private Cluster Access

## Public Access

Allows access to Kubernetes API directly from the internet.

Suitable for:
- Development
- Testing
- Learning environments

---

## Private Access

Restricts API access within the VPC.

Recommended for:
- Production
- Secure enterprise workloads

You may use a bastion host or VPN for cluster access.

---

# Destroy Infrastructure

To remove all resources:

```bash
terraform destroy -var-file=conf/input.tfvars
```

---

# Useful Commands

## Check Terraform State

```bash
terraform show
```

## Format Terraform Files

```bash
terraform fmt -recursive
```

## Validate Configuration

```bash
terraform validate
```

---

# Architecture

```text
                Internet
                    │
            ┌───────┴───────┐
            │ Internet GW   │
            └───────┬───────┘
                    │
         ┌──────────┴──────────┐
         │       AWS VPC       │
         ├─────────────────────┤
         │ Public Subnets      │
         │ Private Subnets     │
         │ NAT Gateway         │
         │ EKS Control Plane   │
         │ Worker Nodes        │
         └─────────────────────┘
```

---

# Security Notes

- Prefer private cluster access for production
- Restrict Security Group ingress rules
- Use IAM Roles for Service Accounts (IRSA)
- Rotate AWS credentials regularly

---

# References

- AWS EKS Documentation  
  https://docs.aws.amazon.com/eks/

- Terraform AWS Provider  
  https://registry.terraform.io/providers/hashicorp/aws/latest

- Terraform EKS Module  
  https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

---

# License

MIT License

---

# Contributing

Pull requests are welcome.

If you'd like to improve the infrastructure or documentation, feel free to open an issue or submit a PR.
