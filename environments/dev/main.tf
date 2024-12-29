module "resource_group" {
  source          = "../../modules/resource-group"
  project         = var.project
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
}
module "key_vault" {
  source          = "../../modules/keyvault"
  project         = var.project
  location        = var.location
  environment     = var.environment
  github_token    = var.github_token
  rg_name         = module.resource_group.resource_group_name
  subscription_id = var.subscription_id
}
module "vnet_aks" {
  source                      = "../../modules/networking"
  project                     = var.project
  location                    = var.location
  network_address_space       = var.network_address_space
  aks_subnet_address_prefix   = var.aks_subnet_address_prefix
  aks_subnet_address_name     = var.aks_subnet_address_name
  appgw_subnet_address_prefix = var.appgw_subnet_address_prefix
  appgw_subnet_address_name   = var.appgw_subnet_address_name
  environment                 = var.environment
  rg_name                     = module.resource_group.resource_group_name
  subscription_id             = var.subscription_id
}

module "loganalytics" {
  source                       = "../../modules/loganalytics"
  log_analytics_workspace_name = var.log_analytics_workspace_name
  location                     = var.location
  resource_group_name          = module.resource_group.resource_group_name
  log_analytics_workspace_sku  = "PerGB2018"
  environment                  = var.environment
  subscription_id              = var.subscription_id
}

module "jenkins" {
  source                  = "../../modules/jenkins"
  network_interface_id    = module.vnet_aks.vniid
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = var.location
  environment             = var.environment
  ssh_public_key          = var.ssh_public_key
  subscription_id         = var.subscription_id
  scfile                  = var.scfile
}

module "aks" {
  source                     = "../../modules/aks-cluster"
  name                       = var.aks_name
  kubernetes_version         = var.kubernetes_version
  agent_count                = var.agent_count
  vm_size                    = var.vm_size
  location                   = var.location
  ssh_public_key             = var.ssh_public_key
  log_analytics_workspace_id = module.loganalytics.id
  aks_subnet                 = module.vnet_aks.aks_subnet_id
  agic_subnet_id             = module.vnet_aks.appgw_subnet_id
  environment                = var.environment
  subscription_id            = var.subscription_id
  resource_group_name        = module.vnet_aks.resource_group

  addons = {
    oms_agent                   = true
    azure_policy                = false
    ingress_application_gateway = true
  }
}

module "acr" {
  source                  = "../../modules/acr"
  name                    = var.acr_name
  environment             = var.environment
  subscription_id         = var.subscription_id
  resource_group_name     = module.vnet_aks.resource_group
  resource_group_location = var.location
  kubelet_object_id       = module.aks.kubelet_object_id
  project                 = var.project
}
