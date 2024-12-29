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
  github_token    = base64decode(var.github_token)
  rg_name         = module.resource_group.resource_group_name
  subscription_id = var.subscription_id
}

module "vnet_aks" {
  source                        = "../../modules/networking"
  project                       = var.project
  location                      = var.location
  environment                   = var.environment
  rg_name                       = module.resource_group.resource_group_name
  subscription_id               = var.subscription_id
  jenkins_network_address_space = var.jenkins_network_address_space
  jenkins_subnet_address        = var.jenkins_subnet_address
  aks_network_address_space     = var.aks_network_address_space
  aks_ingress_subnet_address    = var.aks_ingress_subnet_address
  aks_subnet_address            = var.aks_subnet_address
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
  network_interface_id    = module.vnet_aks.jenkins_vn_iid
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = var.location
  environment             = var.environment
  ssh_public_key          = var.ssh_public_key
  subscription_id         = var.subscription_id
  scfile                  = var.scfile
}

module "aks" {
  source                     = "../../modules/aks-cluster"
  project                    = var.project
  kubernetes_version         = var.kubernetes_version
  agent_count                = var.agent_count
  vm_size                    = var.vm_size
  location                   = var.location
  ssh_public_key             = var.ssh_public_key
  log_analytics_workspace_id = module.loganalytics.id
  aks_subnet                 = module.vnet_aks.aks_subnet_id
  aks_ingress_subnet_id      = module.vnet_aks.aks_ingress_subnet_id
  environment                = var.environment
  subscription_id            = var.subscription_id
  resource_group_name        = module.resource_group.resource_group_name
  addons = {
    oms_agent                   = true
    azure_policy                = false
    ingress_application_gateway = true
  }
}

module "acr" {
  source                  = "../../modules/acr"
  project                 = var.project
  environment             = var.environment
  subscription_id         = var.subscription_id
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = var.location
  kubelet_object_id       = module.aks.kubelet_object_id
}

module "argocd" {
  source                 = "../../modules/argo"
  cluster_endpoint       = module.aks.host
  cluster_ca_certificate = module.aks.cluster_ca_certificate
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  subscription_id        = var.subscription_id
  github_token           = module.key_vault.github_token
}
