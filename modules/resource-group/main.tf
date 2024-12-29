resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-${var.location}-rg"
  location = var.location

  tags = {
    Environment = var.environment
  }
}
