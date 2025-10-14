output "sg_ids_by_service" {
  value = { for k, sg in aws_security_group.svc : k => sg.id }
}
