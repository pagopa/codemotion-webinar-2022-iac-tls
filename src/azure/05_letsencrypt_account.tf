# create let's encrypt account used to create TLS certificates
module "letsencrypt_account" {
  source            = "git::https://github.com/pagopa/azurerm.git//letsencrypt_credential?ref=v2.19.0"
  prefix            = var.prefix
  env               = var.env_short
  le_email          = "foo@pagopa.it"
  key_vault_name    = module.key_vault.name
  subscription_name = data.azurerm_subscription.current.display_name
}
