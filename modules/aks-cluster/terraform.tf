terraform {
    required_version = ">= 1.0.1"
    backend "azurerm" {
    }
    required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}