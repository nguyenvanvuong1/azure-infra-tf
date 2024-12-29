# vm jenkins
resource "azurerm_virtual_network" "jenkins_virtual_network" {
  name                = "${var.project}-${var.environment}-jenkins-vn"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.jenkins_network_address_space]
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "${var.project}-${var.environment}-jenkins-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.jenkins_virtual_network.name
  address_prefixes     = [var.jenkins_subnet_address]

}
resource "azurerm_public_ip" "jenkins_public_ip" {
  name                = "${var.project}-${var.environment}-jenkins-vnpip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}
resource "azurerm_network_interface" "jenkins_nic" {
  name                = "${var.project}-${var.environment}-jenkins-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_public_ip.id
  }

  tags = {
    Environment = var.environment
  }
}

# aks
resource "azurerm_virtual_network" "aks_virtual_network" {
  name                = "${var.project}-${var.environment}-aks-vn"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.aks_network_address_space]
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.project}-${var.environment}-aks-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.aks_virtual_network.name
  address_prefixes     = [var.aks_subnet_address]
}

resource "azurerm_subnet" "aks_ingress_subnet" {
  name                 = "${var.project}-${var.environment}-aks-ingress-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.aks_virtual_network.name
  address_prefixes     = [var.aks_ingress_subnet_address]
}

resource "azurerm_public_ip" "aks_public_ip" {
  name                = "${var.project}-${var.environment}-aks-vnpip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}
# aks network interface
resource "azurerm_network_interface" "aks_nic" {
  name                = "${var.project}-${var.environment}-aks-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aks_public_ip.id
  }

  tags = {
    Environment = var.environment
  }
}
