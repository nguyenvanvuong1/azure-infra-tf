output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "aks_ingress_subnet_id" {
  value = azurerm_subnet.aks_ingress_subnet.id
}

output "jenkins_vn_iid" {
  value = azurerm_network_interface.jenkins_nic.id
}
