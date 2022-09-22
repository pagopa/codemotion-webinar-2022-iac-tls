module "web_test_api_tlsiac_pagopa_it" {
  source = "git::https://github.com/pagopa/azurerm.git//application_insights_web_test_preview?ref=v2.19.1"

  subscription_id                   = data.azurerm_subscription.current.subscription_id
  name                              = "api.${var.dns_zone}.${var.dns_root_domain}-webtest"
  location                          = var.location
  resource_group                    = azurerm_resource_group.resources_rg.name
  application_insight_name          = azurerm_application_insights.application_insights.name
  application_insight_id            = azurerm_application_insights.application_insights.id
  request_url                       = "https://api.${var.dns_zone}.${var.dns_root_domain}"
  ssl_cert_remaining_lifetime_check = 7

  actions = [
    {
      action_group_id = azurerm_monitor_action_group.email.id,
    },
  ]
}
