resource "azurerm_linux_virtual_machine" "vm_jenkins" {
    name                = "jenkins-instance"
    resource_group_name = var.resource_group_name
    location            = var.resource_group_location
    size                = "Standard_DS1_v2"
    admin_username      = "vuongnv"
    
    admin_ssh_key {
      public_key = var.ssh_public_key
      username = "vuongnv"
    }

    tags = {
      Terraform   = "true"
      Environment = var.environment
      Name        = "jenkins"
    }
    
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher          ="Canonical"
        offer              ="0001-com-ubuntu-server-jammy"
        sku                ="22_04-lts-gen2"
        version            ="latest"
    }
    network_interface_ids = [var.network_interface_id]
}

resource "azurerm_network_security_group" "sg_jenkins" {
  name = "sg_jenkins"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  security_rule {
    name = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "allow_8080_jenkins"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "TLS_from_VNET"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
resource "azurerm_virtual_machine_extension" "jenkins_install_software" {
    name                    = "install-az-cli"
    virtual_machine_id      = azurerm_linux_virtual_machine.vm_jenkins.id
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    
    protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.scfile))}"
    }
    PROT
}