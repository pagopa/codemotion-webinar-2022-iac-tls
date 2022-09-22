resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${local.project}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = -1

  tags = var.tags
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${local.project}-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources_rg.name
  application_type    = "other"

  workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  tags = var.tags
}

resource "azurerm_monitor_action_group" "email" {
  name                = "PagoPA"
  resource_group_name = azurerm_resource_group.resources_rg.name
  short_name          = "PagoPA"

  email_receiver {
    name                    = "email"
    email_address           = "foo@pagopa.it"
    use_common_alert_schema = true
  }

  tags = var.tags
}
