output "root_ca_cert" {
  value       = tls_self_signed_cert.root_ca.cert_pem
}

output "root_ca_private_key" {
  value       = tls_private_key.root_ca.private_key_pem
  sensitive   = true
}
