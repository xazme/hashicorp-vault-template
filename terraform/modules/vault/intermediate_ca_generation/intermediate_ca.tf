resource "tls_private_key" "intermediate_ca" {
  algorithm = var.intermediate_ca_key_algorithm
  rsa_bits  = var.intermediate_ca_key_rsa_bits
}

resource "tls_cert_request" "intermediate_ca" {
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem

  subject {
    common_name         = var.intermediate_ca_subject.common_name
    organization        = var.intermediate_ca_subject.organization
    organizational_unit = var.intermediate_ca_subject.organizational_unit
    country             = var.intermediate_ca_subject.country
    province            = var.intermediate_ca_subject.province
    locality            = var.intermediate_ca_subject.locality
  }
}

resource "tls_locally_signed_cert" "intermediate_ca" {
  cert_request_pem   = tls_cert_request.intermediate_ca.cert_request_pem
  ca_private_key_pem = data.terraform_remote_state.root_ca_generation.outputs.root_ca_private_key
  ca_cert_pem        = data.terraform_remote_state.root_ca_generation.outputs.root_ca_cert

  validity_period_hours = var.intermediate_ca_validity_period_hours
  is_ca_certificate     = true
  max_path_length       = 0

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature"
  ]
}
