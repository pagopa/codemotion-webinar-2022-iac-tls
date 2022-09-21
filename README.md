# codemotion-webinar-2022-iac-tls

Coming soon

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
# 2) check delegation
nslookup health.tlsiac.pagopa.it
```

```sh
# 3) create key-vault and access policy
./terraform.sh apply prod \
  -target=module.key_vault \
  -target=azurerm_key_vault_access_policy.adgroup_admin
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
