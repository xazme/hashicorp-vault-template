ui            = true
disable_mlock = true
license_path  = "/vault/config/vault-license.hclic"

api_addr     = "https://vault-3.dev.internal"
cluster_addr = "https://vault-3.dev.internal:8201"
cluster_name = "dev-vault-cluster"

plugin_directory = "/vault/plugins/"
plugin_tmpdir    = "/vault/plugins/tmp"

listener "tcp" {
  address                            = "[::]:8200"
  cluster_address                    = "[::]:8201"
  tls_cert_file                      = "/vault/config/certs/vault.pem"
  tls_key_file                       = "/vault/config/certs/vault.key"
  tls_client_ca_file                 = "/vault/config/certs/ca.pem"
  tls_require_and_verify_client_cert = "true"
}

storage "raft" {
  path    = "/vault/data"
  node_id = "vault-3"

  retry_join {
    leader_api_addr         = "https://vault-1.dev.internal:8200"
    leader_client_cert_file = "/vault/config/certs/vault.pem"
    leader_client_key_file  = "/vault/config/certs/vault.key"
    leader_ca_cert_file     = "/vault/config/certs/ca.pem"
  }

  retry_join {
    leader_api_addr         = "https://vault-2.dev.internal:8200"
    leader_client_cert_file = "/vault/config/certs/vault.pem"
    leader_client_key_file  = "/vault/config/certs/vault.key"
    leader_ca_cert_file     = "/vault/config/certs/ca.pem"
  }
}
