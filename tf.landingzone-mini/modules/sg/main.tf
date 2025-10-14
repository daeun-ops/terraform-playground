# services 맵을 SG 리소스로 변환: for_each + dynamic 블록
resource "aws_security_group" "svc" {
  for_each = var.services

  name        = "sg-${each.key}"
  description = "Service SG: ${each.key}"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "sg-${each.key}" })

  # ingress 규칙: 포트 x CIDR 조합을 2중 loop로 flatten
  dynamic "ingress" {
    for_each = flatten([
      for p in each.value.ports : [
        for c in each.value.cidrs : {
          from = p
          to   = p
          cidr = c
        }
      ]
    ])
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
      description = "port ${ingress.value.from} from ${ingress.value.cidr}"
    }
  }

  # egress 열지 여부를 토글 (보안 요구가 높은 prod에 어필 가능)
  dynamic "egress" {
    for_each = each.value.egress ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow all egress"
    }
  }

  lifecycle {
    create_before_destroy = true
    # prevent_destroy = true # 데모용이면 켜서 더 안전하게 보여줄 수도 있음
  }
}

# 서비스명 -> SG ID 맵으로 예쁘게 출력
output "sg_ids_by_service" {
  value = { for k, sg in aws_security_group.svc : k => sg.id }
}
