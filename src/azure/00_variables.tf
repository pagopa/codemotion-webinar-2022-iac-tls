# general

variable "prefix" {
  type    = string
  default = "tlsiac"
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "env_short" {
  type    = string
  default = "p"
  validation {
    condition = (
      length(var.env_short) <= 1
    )
    error_message = "Max length is 1 chars."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "lock_enabled" {
  type        = bool
  default     = true
  description = "If true, add resource lock"
}

# dns
variable "dns_root_domain" {
  type        = string
  description = "DNS root domain for delegation"
}

variable "dns_zone" {
  type        = string
  description = "DNS zone name"
}

variable "dns_default_ttl_sec" {
  type        = number
  default     = 3600
  description = "DNS Time To Live in seconds"
}
