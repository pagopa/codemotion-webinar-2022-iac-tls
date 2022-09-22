module "key_vault" {
  source                     = "git::https://github.com/pagopa/azurerm.git//key_vault?ref=v2.19.0"
  name                       = "${local.project}-kv"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.resources_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 90
  lock_enable                = var.lock_enabled

  tags = var.tags
}

## admin group policy ##
data "azuread_group" "adgroup_admin" {
  display_name = "dvopla-d-adgroup-admin"
}

resource "azurerm_key_vault_access_policy" "adgroup_admin" {
  key_vault_id = module.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_group.adgroup_admin.object_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", ]
}
