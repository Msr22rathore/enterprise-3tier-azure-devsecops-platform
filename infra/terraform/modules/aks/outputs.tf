output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
output "agic_identity" {
  value = azurerm_kubernetes_cluster.this.ingress_application_gateway
}