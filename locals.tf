locals {
    tags = {
        "Cost Center" = ""
        "OPE"   = "ZMG"
        "Responsible Team" = "Workplace"
        "Usecase" = "Scaling Plan Feature Test"
    }
}

locals {
    resourceGroups = {
        dev = {
            name = "rg-avd-dev-001"
            location = "westeurope"
            tags = local.tags
        }
        vnet = {
            name = "rg-vnet-avd-dev-001"
            location = "westeurope"
            tags = local.tags
        }
        shd = {
            name = "rg-avd-shd-001"
            location = "westeurope"
            tags = local.tags
        }
    }
}

locals {
  secrets = {
    domainJoinUsername = {
      name  = "domainJoinUsername"
      value = var.domainJoinUsername
    },
    domainJoinPassword = {
      name  = "domainJoinPassword"
      value = var.domainJoinPassword
    },
    localAdminUsername = {
      name  = "localAdminUsername"
      value = var.localAdminUsername
    },
    localAdminPassword = {
      name  = "localAdminPassword"
      value = var.localAdminPassword
    }
  }
}

locals {
  subnets = {
    prd = {
      name             = "snet-${var.usecase}-${var.company}-prd-001"
      address_prefixes = cidrsubnet(var.vnetAddressSpace, 2, 0)
    },
    dev = {
      name             = "snet-${var.usecase}-${var.company}-dev-001"
      address_prefixes = cidrsubnet(var.vnetAddressSpace, 2, 1)
    },
    shd = {
      name             = "snet-${var.usecase}-${var.company}-shd-001"
      address_prefixes = cidrsubnet(var.vnetAddressSpace, 2, 2)
    }
  }
}