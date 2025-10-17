output "istio_ingress_lb" {
  description = "Istio ingress service (LoadBalancer) — check EXTERNAL-IP after apply"
  value       = "kubectl -n istio-system get svc istio-ingress -o wide"
}

output "argocd_admin_login" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}
