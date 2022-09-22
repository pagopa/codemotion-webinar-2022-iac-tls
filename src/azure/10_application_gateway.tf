resource "azurerm_public_ip" "application_gateway" {
  name                = "${local.project}-application-gateway-pip"
  resource_group_name = azurerm_resource_group.resources_rg.name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_dns_a_record" "api_tlsiac_pagopa_it" {
  name                = "api"
  zone_name           = azurerm_dns_zone.tlsiac_pagopa_it.name
  resource_group_name = azurerm_resource_group.resources_rg.name
  ttl                 = var.dns_default_ttl_sec
  records             = [azurerm_public_ip.application_gateway.ip_address]

  tags = var.tags
}

module "application_gateway_snet" {
  source               = "git::https://github.com/pagopa/azurerm.git//subnet?ref=v2.19.0"
  name                 = "${local.project}-application-gateway-snet"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.resources_rg.name
  virtual_network_name = module.vnet.name

  service_endpoints = [
    "Microsoft.Web",
  ]
}

resource "azurerm_user_assigned_identity" "application_gateway" {
  resource_group_name = azurerm_resource_group.resources_rg.name
  location            = var.location
  name                = "${local.project}-application-gateway-identity"

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "application_gateway_identity" {
  key_vault_id            = module.key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.application_gateway.principal_id
  key_permissions         = []
  secret_permissions      = []
  certificate_permissions = ["Get", "List"]
  storage_permissions     = []
}

data "azurerm_key_vault_certificate" "api_tlsiac_pagopa_it" {
  name         = replace("api-${var.dns_zone}-${var.dns_root_domain}", ".", "-")
  key_vault_id = module.key_vault.id
}

## Application gateway ##
module "application_gateway" {
  source = "git::https://github.com/pagopa/azurerm.git//app_gateway?ref=v2.19.0"

  resource_group_name = azurerm_resource_group.resources_rg.name
  location            = var.location
  name                = "${local.project}-application-gateway-gw"

  # SKU
  sku_name = "WAF_v2"
  sku_tier = "WAF_v2"

  # Networking
  subnet_id    = module.application_gateway_snet.id
  public_ip_id = azurerm_public_ip.application_gateway.id

  # Configure backends
  backends = {
    api = {
      protocol                    = "Https"
      host                        = module.app_service_app.default_site_hostname
      port                        = 443
      ip_addresses                = null # with null value use fqdns
      fqdns                       = [module.app_service_app.default_site_hostname]
      probe                       = "/"
      probe_name                  = "app"
      request_timeout             = 10
      pick_host_name_from_backend = false
    }
  }

  # Configure listeners
  listeners = {
    api = {
      protocol           = "Https"
      host               = "api.${var.dns_zone}.${var.dns_root_domain}"
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null

      certificate = {
        name = replace("api-${var.dns_zone}-${var.dns_root_domain}", ".", "-")
        id = replace(
          data.azurerm_key_vault_certificate.api_tlsiac_pagopa_it.secret_id,
          "/${data.azurerm_key_vault_certificate.api_tlsiac_pagopa_it.version}",
          ""
        )
      }
    }
  }

  # maps listener to backend
  routes = {
    api = {
      listener              = "api"
      backend               = "api"
      rewrite_rule_set_name = "rewrite-rule-set-api"
    }
  }

  rewrite_rule_sets = [
    {
      name = "rewrite-rule-set-api"
      rewrite_rules = [{
        name          = "http-headers-api"
        rule_sequence = 100
        condition     = null
        request_header_configurations = [
          {
            header_name  = "X-Forwarded-For"
            header_value = "{var_client_ip}"
          },
          {
            header_name  = "X-Client-Ip"
            header_value = "{var_client_ip}"
          },
        ]
        response_header_configurations = []
        url                            = null
      }]
    },
  ]

  trusted_client_certificates = []

  # TLS
  identity_ids = [azurerm_user_assigned_identity.application_gateway.id]

  # Scaling
  app_gateway_min_capacity = 0
  app_gateway_max_capacity = 2

  alerts_enabled = false

  tags = var.tags
}

module "app_service_app" {
  source = "git::https://github.com/pagopa/azurerm.git//app_service?ref=v2.9.1"

  # App service plan
  plan_type     = "internal"
  plan_name     = "${local.project}-app-service-plan"
  plan_kind     = "Linux"
  plan_reserved = true # Mandatory for Linux plan
  plan_sku_tier = "Basic"
  plan_sku_size = "B1"

  # App service
  name                = "${local.project}-app-service-app"
  resource_group_name = azurerm_resource_group.resources_rg.name
  location            = var.location

  always_on        = true
  linux_fx_version = "DOCKER|mcr.microsoft.com/appsvc/staticsite:latest"

  app_settings = {}

  vnet_integration = false

  tags = var.tags
}
