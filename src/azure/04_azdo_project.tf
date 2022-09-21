resource "azuredevops_project" "project" {
  name               = "${local.project}-project"
  description        = "This is the DevOps project for TLS Certificates with Let's Encrypt"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}

resource "azuredevops_project_features" "project_features" {
  project_id = azuredevops_project.project.id
  features = {
    "boards"       = "disabled"
    "repositories" = "disabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
}
