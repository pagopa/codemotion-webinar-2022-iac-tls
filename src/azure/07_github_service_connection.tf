# azure-devops-github-ro-TOKEN is a GitHub PAT token manually set into the key-vault
module "secrets_azdo" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v2.0.5"

  resource_group = "dvopla-d-sec-rg"
  key_vault_name = "dvopla-d-neu-kv"

  secrets = [
    "azure-devops-github-ro-TOKEN",
  ]
}

# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "azure_devop_github_read_only" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "azure_devop_github_read_only"
  auth_personal {
    personal_access_token = module.secrets_azdo.values["azure-devops-github-ro-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}
