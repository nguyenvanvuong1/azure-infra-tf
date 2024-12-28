resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-rg"
  location = var.location
  
  tags = {
    Environment = var.environment
  }
}