variable "root_ca_subject" {
  description = "Distinguished Name (DN) subject attributes for the Root CA"
  type = object({
    common_name         = string
    organization        = string
    organizational_unit = optional(string)
    country             = optional(string)
    province            = optional(string)
    locality            = optional(string)
  })
}

variable "root_ca_validity_period_hours" {
  description = "Validity period in hours for the Root CA certificate"
  type        = number
}

variable "root_ca_key_algorithm" {
  description = "Cryptographic algorithm for the Root CA private key"
  type        = string
}

variable "root_ca_key_rsa_bits" {
  description = "Key size in bits for RSA algorithm"
  type        = number
}
