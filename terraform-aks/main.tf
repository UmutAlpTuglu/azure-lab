# Contains the main resource definitions

# Create a resource group for AKS
resource "azurerm_resource_group" "rg" {
  name     = "aks-demo-rg"
  location = var.location  # Using variable for flexibility
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "aks-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-demo"
  
  identity {
    type = "SystemAssigned"
  }

  # Configure the node pool with cost-optimized settings
  default_node_pool {
    name                = "default"
    node_count          = 1  # Minimum for testing
    vm_size            = "Standard_B2pls_v2"  # Cost-optimized VM size
    enable_auto_scaling = false
  }

  # Use basic load balancer and kubenet for cost optimization
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }
}