# Defines what information to show after apply

# Output the resource group name
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# Output the AKS cluster name
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

# Output the kube config for cluster access
output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}