resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.namespace.metadata.0.name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.1.0"

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = ""
  }
  set {
    name  = "controller.podAnnotations.co\\.elastic\\.logs/enabled"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.co\\.elastic\\.logs/module"
    value = "nginx"
  }
  set {
    name  = "controller.podAnnotations.co\\.elastic\\.logs/fileset\\.stdout"
    value = "ingress_controller"
  }
  set {
    name  = "controller.podAnnotations.co\\.elastic\\.logs/fileset\\.stderr"
    value = "error"
  }
  set {
    name  = "controller.podLabels.app"
    value = "nginx"
  }
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = true
    type  = "string"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = 10254
    type  = "string"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/path"
    value = "/metrics"
  }

  set {
    name  = "controller.service.internal.enabled"
    value = var.internal_loadbalancer
  }

  set {
    name  = "controller.service.internal.annotations.networking\\.gke\\.io/load-balancer-type"
    value = "Internal"
  }

  set {
    name  = "controller.replicaCount"
    value = var.replica_count
  }
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "${helm_release.nginx_ingress.name}-controller"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  depends_on = [helm_release.nginx_ingress]
}

data "kubernetes_service" "nginx_ingress_internal" {
  count = var.internal_loadbalancer ? 1 : 0
  metadata {
    name      = "${helm_release.nginx_ingress.name}-controller-internal"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  depends_on = [helm_release.nginx_ingress]
}

