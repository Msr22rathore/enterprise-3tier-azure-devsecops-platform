resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  
  dynamic "ingress_application_gateway" {
    for_each = var.application_gateway_id != null ? [1] : []

    content {
      gateway_id = var.application_gateway_id
    }
  }
  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.subnet_id

    type = "VirtualMachineScaleSets"
     upgrade_settings {
    max_surge = "10%"
  }
 auto_scaling_enabled = true
  min_count            = 1
  max_count            = 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"

    load_balancer_sku = "standard"  
       
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = var.tags
}