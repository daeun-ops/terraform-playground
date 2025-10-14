data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

# OIDC provider for IRSA
data "aws_iam_openid_connect_provider" "oidc" {
  arn = data.aws_eks_cluster.this.identity[0].oidc[0].issuer_arn
}

locals {
  cluster_oidc_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  cluster_oidc_arn = data.aws_iam_openid_connect_provider.oidc.arn
}

# IRSA roles for each microservice
module "irsa_roles" {
  source     = "./modules/irsa"
  for_each   = var.services
  service    = each.key
  sa_name    = each.value.service_account
  namespace  = var.namespace
  policy_tpl = each.value.policy_template
  oidc_url   = local.cluster_oidc_url
  oidc_arn   = local.cluster_oidc_arn
}

output "irsa_role_arns" {
  description = "ARNs for each service's IAM role"
  value       = { for s, m in module.irsa_roles : s => m.role_arn }
}
