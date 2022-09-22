module "vnet" {
  source              = "git::https://github.com/pagopa/azurerm.git//virtual_network?ref=v2.19.0"
  name                = "${local.project}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}
