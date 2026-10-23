variable "vault_cert_subject" {
  type = object({
    country             = string
    province            = string
    locality            = string
    organization        = string
    organizational_unit = string
  })
}

variable "vault_nodes_config" {
  type = map(object({
    common_name  = string
    dns_names    = list(string)
    ip_addresses = list(string)
  }))
}

variable "vault_cert_validity_period_hours" {
  type    = number
  default = 43800 # 5 years
}

variable "vault_key_algorithm" {
  type    = string
  default = "RSA"
}

variable "vault_key_rsa_bits" {
  type    = number
  default = 2048
}

variable "vault_certs_output_dir" {
  type = string
}
