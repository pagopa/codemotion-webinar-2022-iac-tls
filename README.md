# codemotion-webinar-2022-iac-tls

## Prerequisiti

- terraform cli
- azure cli
- docker cli
- Azure subscription
- Azure DevOps organization
- (opzionale) pre-commit-terraform (https://github.com/antonbabenko/pre-commit-terraform#how-to-install)

## Live Demo

```sh
# 0) create terraform backend
./init.sh apply DevOpsLab
```

```sh
# 1) create resource groups and dns zones
./terraform.sh apply prod \
  -target=azurerm_resource_group.default_roleassignment_rg \
  -target=azurerm_resource_group.resources_rg \
  -target=azurerm_dns_zone.tlsiac_pagopa_it \
  -target=azurerm_dns_caa_record.tlsiac_pagopa_it \
  -target=azurerm_dns_a_record.health
```

```sh
# 2) create key-vault and access policy
./terraform.sh apply prod \
  -target=module.key_vault \
  -target=azurerm_key_vault_access_policy.adgroup_admin
```

```sh
# 3) check delegation
nslookup health.tlsiac.pagopa.it
```

```sh
# 4) create Azure DevOps project
./terraform.sh apply prod \
  -target=azuredevops_project.project \
  -target=azuredevops_project_features.project_features
```

```sh
# 5) create Let's Encrypt account
./terraform.sh apply prod \
  -target=module.letsencrypt_account
```

```sh
# 6) create key-vault service connection for Azure DevOps
./terraform.sh apply prod \
  -target=module.tls_cert_service_conn \
  -target=azurerm_key_vault_access_policy.tls_cert_service_conn
```

```sh
# 7) create GitHub Service connection for Azure DevOps
./terraform.sh apply prod \
  -target=azuredevops_serviceendpoint_github.azure_devop_github_read_only
```

```sh
# 8) create Azure DevOps pipeline for TLS cert generation
./terraform.sh apply prod \
  -target=module.azuredevops_build_definition_tls_cert_tls_cert_api_tlsiac_pagopa_it
```

```sh
# 9) create virtual network
./terraform.sh apply prod \
  -target=module.vnet
```

```sh
# 10) create application gateway
./terraform.sh apply prod \
  -target=azurerm_public_ip.application_gateway \
  -target=azurerm_dns_a_record.api_tlsiac_pagopa_it \
  -target=module.application_gateway_snet \
  -target=azurerm_user_assigned_identity.application_gateway \
  -target=azurerm_key_vault_access_policy.application_gateway_identity \
  -target=module.application_gateway \
  -target=module.app_service_app
```

```sh
# 11) create monitoring
./terraform.sh apply prod \
  -target=azurerm_log_analytics_workspace.log_analytics_workspace \
  -target=azurerm_application_insights.application_insights \
  -target=azurerm_monitor_action_group.email
```

```sh
# 12) create monitoring for TLS endpoint
./terraform.sh apply prod \
  -target=module.web_test_api_tlsiac_pagopa_it
```
