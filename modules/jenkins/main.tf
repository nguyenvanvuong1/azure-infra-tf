locals {
  user_data = <<-EOT
    #!/bin/bash
    echo "Copying the SSH Key Of Jenkins to the server"
    echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIT0zoLsuk0dkFu4lCI4qycBTuQPMtDO3d/9GHG491mDdmGI3vkRQplUrgQubzcsxTmQzcn+tpHIhHqwM6+t8azCA6KWrWrohIjQhMYDiE9snK+qdSNwqxX5O6kyqSAFsQPSqe20ruTrRynICbpU9c5vj/7HuuIDQRPe/1xJaBQ+u1M0X48mSZvY/GAiAYJ/2eNc9UfocT7KrEFPhbB7eVbSdEQHIBuDqyPnB51u9a3NcouofmtIl5xpwKtKBFXYmhcO4ECUHOd4xQBuh3fAaVSStWDyX5xjPgkGLCI66DXXuoi7hw41twMW5D5gBOS/TPImstY3ktPpCW/p64GwM7VpnbypvJzRzzxcw4dleIUGMQFBAqbMomW/WdiTeRhjNMFPW6w9iPwyO7tZjnhzFxnQ5e1cNRWNdd0Ma1DFVnvoN7TMwr7sw0qIdCbOcXa8vSjkVlgdSadNArhcWuLe/psGUPn+3ASStfwNQ5Gd/YkVCXjVY4HHfHvr4DzCcQ4wk= vuongnguyenvan@VNNOT01466.local" >> /home/ubuntu/.ssh/authorized_keys
    ## install java 17
    apt update && apt install curl wget openjdk-17-jre openjdk-17-jdk -y
    ##  install jenkin
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ |  tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update && apt-get install jenkins -y
    systemctl enable jenkins && systemctl start jenkins
    ## install docker
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl enable docker && systemctl start docker
    # Add Jenkins user into docker group
    usermod -aG docker jenkins

    ## install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client

    ## install trivy
    # Debian/Ubuntu
    apt-get install wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key |  apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main |  tee -a /etc/apt/sources.list.d/trivy.list
    apt-get update
    apt-get install trivy -y
    # Refer: https://aquasecurity.github.io/trivy/v0.29.2/getting-started/installation/
    # install azure cli
    curl -L https://aka.ms/InstallAzureCli | bash
    az --version

  EOT
}

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
    user_data = base64encode(local.user_data)
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
    name = "TLS_from_VNET"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "allow_8080_jenkins"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "allow_ssh_jenkins"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}