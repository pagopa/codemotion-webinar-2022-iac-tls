# Important: reserved resource group, do not create any resource inside it
resource "azurerm_resource_group" "default_roleassignment_rg" {
  name     = "${local.project}-default-roleassignment-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "resources_rg" {
  name     = "${local.project}-resources-rg"
  location = var.location

  tags = var.tags
}
