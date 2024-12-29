provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  load_config_file       = false
}
