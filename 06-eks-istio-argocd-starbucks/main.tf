########################################
# Namespaces
########################################
locals {
  ns_with_injection = toset(["prod", "dev", "qa"])
  namespaces        = toset(["prod", "dev", "qa", "admin", "team-1", "security-team"])
  system_namespaces = toset(["istio-system", "argocd", "monitoring"])
}

resource "kubernetes_namespace_v1" "system" {
  for_each = local.system_namespaces
  metadata { name = each.key }
}

resource "kubernetes_namespace_v1" "app" {
  for_each = local.namespaces
  metadata {
    name = each.key
    labels = (
      contains(local.ns_with_injection, each.key)
      ? { "istio-injection" = "enabled" }
      : null
    )
  }
}

########################################
# Per-namespace Secret ServiceAccount + RBAC
########################################
# Role: read-only access to Secrets in each namespace
resource "kubernetes_role_v1" "secrets_ro" {
  for_each = local.namespaces
  metadata {
    name      = "secrets-readonly"
    namespace = each.key
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

# ServiceAccount per namespace dedicated for secret access
resource "kubernetes_service_account_v1" "sa_secrets" {
  for_each = local.namespaces
  metadata {
    name      = "sa-${each.key}-secrets"
    namespace = each.key
    annotations = {
      "purpose" = "secret-access"
    }
  }
}

resource "kubernetes_role_binding_v1" "rb_secrets" {
  for_each = local.namespaces
  metadata {
    name      = "rb-secrets-readonly"
    namespace = each.key
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.secrets_ro[each.key].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.sa_secrets[each.key].metadata[0].name
    namespace = each.key
  }
}

########################################
# Helm: Istio (base -> istiod -> ingress)
########################################
data "helm_repository" "istio" {
  name = "istio"
  url  = "https://istio-release.storage.googleapis.com/charts"
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = data.helm_repository.istio.url
  chart      = "base"
  namespace  = "istio-system"
  version    = "1.22.1"
  wait       = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = data.helm_repository.istio.url
  chart      = "istiod"
  namespace  = "istio-system"
  version    = "1.22.1"
  wait       = true

  depends_on = [helm_release.istio_base]
  values = [file("${path.module}/helm/istio-values.yaml")]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = data.helm_repository.istio.url
  chart      = "gateway"
  namespace  = "istio-system"
  version    = "1.22.1"
  wait       = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [helm_release.istiod]
}

########################################
# Helm: Argo CD
########################################
data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = data.helm_repository.argo.url
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.52.1"
  wait       = true
  values     = [file("${path.module}/helm/argocd-values.yaml")]
}

########################################
# Helm: kube-prometheus-stack (Prometheus/Grafana)
########################################
data "helm_repository" "prom" {
  name = "prom"
  url  = "https://prometheus-community.github.io/helm-charts"
}

resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  repository = data.helm_repository.prom.url
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "66.2.1"
  wait       = true

  values = [file("${path.module}/monitoring/kube-prometheus-values.yaml")]

  # CRDs installed by chart; Helm provider handles hooks if present
  timeout = 1200
}

########################################
# PROD: DaemonSet (node-wide agent placeholder)
########################################
resource "kubernetes_daemon_set_v1" "prod_node_agent" {
  metadata {
    name      = "prod-node-sidecar"
    namespace = "prod"
    labels    = { app = "prod-node-sidecar" }
  }
  spec {
    selector { match_labels = { app = "prod-node-sidecar" } }
    template {
      metadata { labels = { app = "prod-node-sidecar" } }
      spec {
        service_account_name = kubernetes_service_account_v1.sa_secrets["prod"].metadata[0].name
        container {
          name  = "agent"
          image = "busybox:1.36"
          args  = ["sh", "-c", "while true; do echo $(date) prod-daemon alive; sleep 60; done"]
        }
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
  depends_on = [helm_release.istiod]
}

########################################
# PROD: ML pipeline CronJob (hourly)
########################################
resource "kubernetes_cron_job_v1" "ml_pipeline" {
  metadata {
    name      = "ml-pipeline-trainer"
    namespace = "prod"
    labels    = { app = "ml-pipeline" }
  }
  spec {
    schedule                      = "0 * * * *" # hourly
    successful_jobs_history_limit = 1
    failed_jobs_history_limit     = 3
    job_template {
      metadata { labels = { app = "ml-pipeline" } }
      spec {
        template {
          metadata { labels = { app = "ml-pipeline" } }
          spec {
            service_account_name = kubernetes_service_account_v1.sa_secrets["prod"].metadata[0].name
            restart_policy       = "OnFailure"
            container {
              name  = "trainer"
              image = "python:3.11-slim"
              command = ["bash", "-lc"]
              args = [
                "echo \"[ML] Feature extraction → training → metrics push\"; sleep 10"
              ]
              env {
                name  = "ENV"
                value = "prod"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.kube_prometheus]
}
