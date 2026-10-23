resource "tls_private_key" "vault" {
  for_each  = var.vault_nodes_config
  algorithm = var.vault_key_algorithm
  rsa_bits  = var.vault_key_rsa_bits
}

resource "tls_cert_request" "vault" {
  for_each        = var.vault_nodes_config
  private_key_pem = tls_private_key.vault[each.key].private_key_pem

  subject {
    country             = var.vault_cert_subject.country
    province            = var.vault_cert_subject.province
    locality            = var.vault_cert_subject.locality
    organization        = var.vault_cert_subject.organization
    organizational_unit = var.vault_cert_subject.organizational_unit
    common_name         = each.value.common_name
  }

  dns_names    = each.value.dns_names
  ip_addresses = each.value.ip_addresses
}

resource "tls_locally_signed_cert" "vault" {
  for_each           = var.vault_nodes_config
  cert_request_pem   = tls_cert_request.vault[each.key].cert_request_pem
  ca_private_key_pem = data.terraform_remote_state.intermediate_ca_generation.outputs.intermediate_ca_private_key
  ca_cert_pem        = data.terraform_remote_state.intermediate_ca_generation.outputs.intermediate_ca_cert

  validity_period_hours = var.vault_cert_validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}

resource "local_file" "vault_key_file" {
  for_each = var.vault_nodes_config
  content  = tls_private_key.vault[each.key].private_key_pem
  filename = "${path.cwd}/${var.vault_certs_output_dir}/vault-${each.key}/vault.key"

  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "vault_cert_file" {
  for_each = var.vault_nodes_config
  content  = tls_locally_signed_cert.vault[each.key].cert_pem
  filename = "${path.cwd}/${var.vault_certs_output_dir}/vault-${each.key}/vault.pem"

  file_permission      = "0644"
  directory_permission = "0755"
}

resource "local_file" "ca_file" {
  for_each = var.vault_nodes_config
  content  = data.terraform_remote_state.intermediate_ca_generation.outputs.ca_chain
  filename = "${path.cwd}/${var.vault_certs_output_dir}/vault-${each.key}/ca.pem"

  file_permission      = "0644"
  directory_permission = "0755"
}
