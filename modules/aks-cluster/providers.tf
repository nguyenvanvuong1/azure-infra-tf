provider "azurerm" {
  subscription_id = var.subscription_id
  use_oidc        = true
  features {}
}

provider "kubernetes" {
  host                   = module.k8s.kube_admin_config.0.host
  cluster_ca_certificate = base64decode(module.k8s.kube_admin_config.0.cluster_ca_certificate)
  client_certificate     = base64decode(module.k8s.kube_admin_config.0.client_certificate)
  client_key             = base64decode(module.k8s.kube_admin_config.0.client_key)

  # using kubelogin to get an AAD token for the cluster.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 6dae42f8-4368-4678-94ff-3960e28e3630 in any environments.
      "--client-id",
      azuread_application.app.application_id, # SPN App Id created via terraform
      "--client-secret",
      azuread_service_principal_password.spn_password.value,
      "--tenant-id",
      data.azurerm_subscription.current.tenant_id, # AAD Tenant Id
      "--login",
      "spn"
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.k8s.kube_admin_config.0.host
    cluster_ca_certificate = base64decode(module.k8s.kube_admin_config.0.cluster_ca_certificate)
    client_certificate     = base64decode(module.k8s.kube_admin_config.0.client_certificate)
    client_key             = base64decode(module.k8s.kube_admin_config.0.client_key)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      # This requires the awscli to be installed locally where Terraform is executed
      args = [
        "get-token",
        "--environment",
        "AzurePublicCloud",
        "--server-id",
        data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 6dae42f8-4368-4678-94ff-3960e28e3630 in any environments.
        "--client-id",
        azuread_application.app.application_id, # SPN App Id created via terraform
        "--client-secret",
        azuread_service_principal_password.spn_password.value,
        "--tenant-id",
        data.azurerm_subscription.current.tenant_id, # AAD Tenant Id
        "--login",
        "spn"
      ]
    }
  }
}

provider "kubectl" {
  host                   = module.k8s.kube_admin_config.0.host
  cluster_ca_certificate = base64decode(module.k8s.kube_admin_config.0.cluster_ca_certificate)
  client_certificate     = base64decode(module.k8s.kube_admin_config.0.client_certificate)
  client_key             = base64decode(module.k8s.kube_admin_config.0.client_key)
  apply_retry_count      = 5
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    # This requires the awscli to be installed locally where Terraform is executed
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 6dae42f8-4368-4678-94ff-3960e28e3630 in any environments.
      "--client-id",
      azuread_application.app.application_id, # SPN App Id created via terraform
      "--client-secret",
      azuread_service_principal_password.spn_password.value,
      "--tenant-id",
      data.azurerm_subscription.current.tenant_id, # AAD Tenant Id
      "--login",
      "spn"
    ]
  }
}
