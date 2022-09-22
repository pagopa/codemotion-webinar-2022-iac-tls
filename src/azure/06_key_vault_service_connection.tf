module "tls_cert_service_conn" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_azurerm_limited?ref=v2.6.4"

  project_id                       = azuredevops_project.project.id
  renew_token                      = local.renew_token
  name                             = "${local.project}-tls-cert"
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  subscription_id                  = data.azurerm_subscription.current.subscription_id
  subscription_name                = data.azurerm_subscription.current.display_name
  default_roleassignment_rg_prefix = "${local.project}-"

  credential_subcription              = data.azurerm_subscription.current.display_name
  credential_key_vault_name           = module.key_vault.name
  credential_key_vault_resource_group = azurerm_resource_group.resources_rg.name
}

resource "azurerm_key_vault_access_policy" "tls_cert_service_conn" {
  key_vault_id = module.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.tls_cert_service_conn.service_principal_object_id

  certificate_permissions = ["Get", "Import"]
}
