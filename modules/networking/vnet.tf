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