resource "azurerm_dns_zone" "tlsiac_pagopa_it" {
  name                = "${var.dns_zone}.${var.dns_root_domain}"
  resource_group_name = azurerm_resource_group.resources_rg.name

  tags = var.tags
}

resource "azurerm_dns_caa_record" "tlsiac_pagopa_it" {
  name                = "@"
  zone_name           = azurerm_dns_zone.tlsiac_pagopa_it.name
  resource_group_name = azurerm_resource_group.resources_rg.name
  ttl                 = var.dns_default_ttl_sec

  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }

  record {
    flags = 0
    tag   = "iodef"
    value = "mailto:security+caa@pagopa.it"
  }

  tags = var.tags
}

# health records
# health.tlsiac.pagopa.it
resource "azurerm_dns_a_record" "health" {
  name                = "health"
  zone_name           = azurerm_dns_zone.tlsiac_pagopa_it.name
  resource_group_name = azurerm_resource_group.resources_rg.name
  ttl                 = var.dns_default_ttl_sec
  records             = ["0.0.0.0"]

  tags = var.tags
}
