output "name" {
  value = var.create_service ? kubernetes_service.service.0.metadata.0.name : null
}

output "IMAGE_TAG" {
  value = local.IMAGE_TAG
}
