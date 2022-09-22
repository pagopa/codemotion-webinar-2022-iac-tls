# azure-devops-github-ro-TOKEN is a GitHub PAT token manually set into the key-vault
data "azurerm_key_vault_secret" "azure_devops_github_ro_TOKEN" {
  name         = "azure-devops-github-ro-TOKEN"
  key_vault_id = module.key_vault.id
}

# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "azure_devop_github_read_only" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "azure_devop_github_read_only"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.azure_devops_github_ro_TOKEN.value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}
