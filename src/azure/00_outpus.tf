output "dns_tlsiac_name_servers" {
  value = azurerm_dns_zone.tlsiac_pagopa_it.name_servers
}

output "azure_devops_project_name" {
  value = azuredevops_project.project.name
}
