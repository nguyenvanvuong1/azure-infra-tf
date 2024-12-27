resource "azurerm_resource_group" "vnet_resource_group" {
  name     = "${var.name}-rg"
  location = var.location
  
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name = var.name
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  address_space = [var.network_address_space]

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name = var.aks_subnet_address_name
  resource_group_name  = azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.aks_subnet_address_prefix]
  
}

resource "azurerm_subnet" "appgw_subnet" {
  name = var.appgw_subnet_address_name
  resource_group_name  = azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.appgw_subnet_address_prefix]
  
}

resource "azurerm_public_ip" "vnet_public_ip" {
  name                = "${var.name}-publicip1"
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_network_interface" "vnet_interface" {
  name                = "${var.name}-nic"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vnet_public_ip.id
  }

  tags = {
    Environment = var.environment
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "github_token" {
  name                        = "${var.project}-${var.environment}-github-token"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.vnet_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]

    secret_permissions = [
      "Get",
      "Set"
    ]

    storage_permissions = [
      "Get",
      "Set"
    ]
  }
}
