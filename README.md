# terraform-playground🌳

## Terraform Infrastructure as Code – E-Commerce Platform

This repository demonstrates production-grade Terraform patterns for building and operating an AWS-based e-commerce infrastructure.  
Each directory represents a distinct IaC concept – from basic for-expressions to full environment-aware, data-driven modules.

---

## 📁 Directory Structure

| Directory | Description |
|------------|-------------|
| 01-for-expression-basic | Fundamental Terraform `for` loop examples |
| 02-landingzone-mini | Multi-environment (dev/stage/prod) VPC and networking automation |
| 03-eks-irsa-demo | EKS cluster with IRSA-based IAM roles for service accounts (e-commerce microservices) |
| 04-cloudwatch-alarms | Automated monitoring and alerting configuration |
| 05-github-actions-ci | Terraform validation and plan CI workflow using GitHub Actions |

---

## 🧠 Highlights
- **Workspace-driven environments** (dev/stage/prod)
- **Modular architecture** for VPC, EKS, Security, and Monitoring
- **IRSA (IAM Roles for Service Accounts)** for fine-grained microservice access
- **Dynamic and composable HCL** with `for_each`, `flatten`, `templatefile`, and `dynamic` blocks
- **Policy-as-Code** through data templates and versioned IAM definitions
- **GitHub Actions CI/CD** pipeline for validation and plan previews

---

## 🚀 Getting Started
```bash
# Select your AWS profile and region
export AWS_PROFILE=default
export AWS_REGION=ap-northeast-2

# Initialize
terraform init

# Select workspace
terraform workspace new dev || true
terraform workspace select dev

# Plan with environment vars
terraform plan -var-file="envs.tfvars.example"

# (Optional) Apply — may incur AWS costs
# terraform apply -var-file="envs.tfvars.example"
