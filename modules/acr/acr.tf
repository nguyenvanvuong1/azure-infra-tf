resource "azurerm_container_registry" "acr" {
  name                = "${var.project}${var.environment}acr"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Premium"
  admin_enabled       = false
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_role_assignment" "acr" {
  principal_id                     = var.kubelet_object_id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
  scope                            = azurerm_container_registry.acr.id
}
