output "external_loadbalancer_ip" {
  value = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.ip
}

output "internal_loadbalancer_ip" {
  value = var.internal_loadbalancer ? data.kubernetes_service.nginx_ingress_internal.0.status.0.load_balancer.0.ingress.0.ip : ""
}