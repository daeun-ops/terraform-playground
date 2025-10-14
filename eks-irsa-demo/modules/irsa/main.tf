locals {
  sa_fqdn = "system:serviceaccount:${var.namespace}:${var.sa_name}"

  # Render the service-specific IAM policy using a templatefile
  rendered_policy = templatefile(var.policy_tpl, {
    service = var.service
  })
}

resource "aws_iam_policy" "this" {
  name        = "policy-${var.service}"
  description = "IAM policy for ${var.service} microservice"
  policy      = local.rendered_policy
}

resource "aws_iam_role" "this" {
  name               = "irsa-role-${var.service}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_url, "https://", "")}:sub" = local.sa_fqdn
          }
        }
      }
    ]
  })

  tags = {
    service = var.service
    managed_by = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
