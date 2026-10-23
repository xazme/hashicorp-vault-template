resource "tls_private_key" "root_ca" {
  algorithm = var.root_ca_key_algorithm
  rsa_bits  = var.root_ca_key_rsa_bits
}

resource "tls_self_signed_cert" "root_ca" {
  private_key_pem = tls_private_key.root_ca.private_key_pem

  subject {
    country             = var.root_ca_subject.country
    province            = var.root_ca_subject.province
    locality            = var.root_ca_subject.locality
    organization        = var.root_ca_subject.organization
    organizational_unit = var.root_ca_subject.organizational_unit
    common_name         = var.root_ca_subject.common_name
  }

  validity_period_hours = var.root_ca_validity_period_hours
  is_ca_certificate     = true
  max_path_length       = 1

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}
