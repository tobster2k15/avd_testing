terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.33.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.8.0"
    }
  }
}

provider "azurerm"{
    features {}
}

resource "azurerm_resource_group" "this" {
  for_each = local.resourceGroups
  name = each.value.name
  location = each.value.location
  tags = each.value.tags
}

module "networking" {
  source              = "./modules/zmg-it-wp-terraform-network-module"
  resource_group_name = azurerm_resource_group.this["vnet"].name
  vnetName            = "vnet-${var.usecase}-${var.company}-prd-001"
  addressSpace        = [var.vnetAddressSpace]
  dnsServer           = var.dnsServer
  subnets             = local.subnets
  tags                = local.tags

  depends_on = [azurerm_resource_group.this]
}

module "keyVault" {
    source = "./modules/zmg-it-wp-terraform-keyvault-module"
    kvName = "kv-${var.usecase}-${var.company}-shd-001"
    secrets = local.secrets
    resource_group_name = azurerm_resource_group.this["shd"].name
    tags = local.tags
    depends_on = [ azurerm_resource_group.this ]
}

module "avd" {
    source = "./modules/zmg-it-wp-terraform-avd-session-host-config-module"
    resource_group_name = azurerm_resource_group.this["dev"].name
  company             = var.company
  environment         = "prd"
  usecase             = var.usecase
  tags                = local.tags
  domainInfo = {
    joinType = "ActiveDirectory"
    activeDirectoryInfo = {
      domainCredentials = {
        usernameKeyVaultSecretUri = module.keyVault.secretVersionlessUris["domainJoinUsername"]
        passwordKeyVaultSecretUri = module.keyVault.secretVersionlessUris["domainJoinPassword"]
      }
      ouPath     = "OU=Path,OU=To,OU=Your,OU=Unit,DC=Your-LocalDomain,DC=local"
      domainName = "Your-LocalDomain.local"
    }
  }
  usernameKeyVaultSecretUri = module.keyVault.secretVersionlessUris["localAdminUsername"]
  passwordKeyVaultSecretUri = module.keyVault.secretVersionlessUris["localAdminPassword"]
  imageInfo = {
    type = "Marketplace"
  }
  networkInfo = {
    subnetId = module.networking.subnetId["dev"]
  }
  vmSizeId                       = "Standard_D4s_v4"
  managedDiskType                = "Premium_LRS"
  securityInfo                   = {}
  bootDiagnosticsInfo            = {}
  failedSessionHostCleanupPolicy = "KeepNone"
  avdUsers                       = [""]
  scalingPlan = {
    enabled = false
    details = {}
  }
  depends_on = [ module.keyVault,  ]
}