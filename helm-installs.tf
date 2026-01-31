resource "kubernetes_namespace_v1" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata { name = "argocd" }
}

resource "kubernetes_namespace_v1" "datadog" {
  metadata { name = "datadog" }
}

# ingress-nginx (NLB)
# ingress-nginx
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  # ⬅️ غيّر المرجع هنا
  namespace = kubernetes_namespace_v1.ingress_nginx.metadata[0].name
  version   = "4.11.1"

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.this]
}

# Argo CD
resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # ⬅️ غيّر المرجع هنا
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  version   = "7.7.12"

  values = [
    yamlencode({
      server = {
        service = { type = "LoadBalancer" }
      }
    })
  ]

  depends_on = [aws_eks_node_group.this]
}

# Datadog
resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = kubernetes_namespace_v1.datadog.metadata[0].name
  # version  = "3.80.6"   # ← احذف السطر ده

  values = [
    yamlencode({
      datadog = {
        site = var.datadog_site
        logs = { enabled = true }
        apm  = { enabled = true }
      }
      providers = { eks = { enabled = true } }
      agents = {
        containers = { agent = { env = [{
          name = "DD_API_KEY",
          valueFrom = { secretKeyRef = { name = "datadog-secret", key = "api-key" } }
        }]}}
      }
    })
  ]

  depends_on = [aws_eks_node_group.this]
}