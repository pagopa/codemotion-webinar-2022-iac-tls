locals {
  tls_cert_api_tlsiac_pagopa_it = {

    repository = {
      organization   = "pagopa"
      name           = "le-azure-acme-tiny"
      branch_name    = "refs/heads/master"
      pipelines_path = "."
    }

    pipeline = {
      path            = "TLS-Certificates"
      dns_record_name = "api"
      dns_zone_name   = "${var.dns_zone}.${var.dns_root_domain}"
    }

    variables = {
      cert_name_expire_seconds     = "2592000" #30 days
      key_vault_service_connection = module.tls_cert_service_conn.service_endpoint_name,
      key_vault_name               = module.key_vault.name
    }

    variables_secret = {
    }

    config = {
      tenant_id                           = data.azurerm_client_config.current.tenant_id
      subscription_name                   = data.azurerm_subscription.current.display_name
      subscription_id                     = data.azurerm_subscription.current.subscription_id
      dns_zone_resource_group             = azurerm_resource_group.resources_rg.name
      credential_subcription              = data.azurerm_subscription.current.display_name
      credential_key_vault_name           = module.key_vault.name
      credential_key_vault_resource_group = azurerm_resource_group.resources_rg.name

      service_connection_ids_authorization = [
        module.tls_cert_service_conn.service_endpoint_id,
      ]

      schedules = {
        days_to_build              = ["Wed"]
        schedule_only_with_changes = false
        start_hours                = 18
        start_minutes              = 00
        time_zone                  = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
        branch_filter = {
          include = ["master"]
          exclude = []
        }
      }
    }
  }
}

module "azuredevops_build_definition_tls_cert_tls_cert_api_tlsiac_pagopa_it" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert?ref=v2.4.0"

  project_id                   = azuredevops_project.project.id
  repository                   = local.tls_cert_api_tlsiac_pagopa_it.repository
  name                         = "${local.tls_cert_api_tlsiac_pagopa_it.pipeline.dns_record_name}.${local.tls_cert_api_tlsiac_pagopa_it.pipeline.dns_zone_name}"
  renew_token                  = local.renew_token
  path                         = local.tls_cert_api_tlsiac_pagopa_it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.azure_devop_github_read_only.id

  dns_record_name         = local.tls_cert_api_tlsiac_pagopa_it.pipeline.dns_record_name
  dns_zone_name           = local.tls_cert_api_tlsiac_pagopa_it.pipeline.dns_zone_name
  dns_zone_resource_group = local.tls_cert_api_tlsiac_pagopa_it.config.dns_zone_resource_group
  tenant_id               = local.tls_cert_api_tlsiac_pagopa_it.config.tenant_id
  subscription_name       = local.tls_cert_api_tlsiac_pagopa_it.config.subscription_name
  subscription_id         = local.tls_cert_api_tlsiac_pagopa_it.config.subscription_id

  credential_subcription              = local.tls_cert_api_tlsiac_pagopa_it.config.credential_subcription
  credential_key_vault_name           = local.tls_cert_api_tlsiac_pagopa_it.config.credential_key_vault_name
  credential_key_vault_resource_group = local.tls_cert_api_tlsiac_pagopa_it.config.credential_key_vault_resource_group

  variables = merge(
    local.tls_cert_api_tlsiac_pagopa_it.variables,
  )

  variables_secret = merge(
    local.tls_cert_api_tlsiac_pagopa_it.variables_secret,
  )

  service_connection_ids_authorization = local.tls_cert_api_tlsiac_pagopa_it.config.service_connection_ids_authorization

  schedules = local.tls_cert_api_tlsiac_pagopa_it.config.schedules
}
