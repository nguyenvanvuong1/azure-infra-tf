# vn
resource "azurerm_virtual_network" "virtual_network" {
  name = "${var.project}-vn"
  location = var.location
  resource_group_name = var.rg_name
  address_space = [var.network_address_space]
  tags = {
    Environment = var.environment
  }
}
# subnet
resource "azurerm_subnet" "aks_subnet" {
  name = "${var.aks_subnet_address_name}-aks-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.aks_subnet_address_prefix]
  
}

resource "azurerm_subnet" "appgw_subnet" {
  name = "${var.appgw_subnet_address_name}-app-gw-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.appgw_subnet_address_prefix]
  
}
# public ip
resource "azurerm_public_ip" "vnet_public_ip" {
  name                = "${var.project}-vnet-public-ip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}
# network interface
resource "azurerm_network_interface" "vnet_interface" {
  name                = "${var.project}-nic"
  location = var.location
  resource_group_name = var.rg_name

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
