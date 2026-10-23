#!/bin/bash
set -e

echo "==> Creating persistent Docker volumes..."
docker volume create vault-data-1
docker volume create vault-data-2
docker volume create vault-data-3

echo "==> Generating Root CA..."
terraform -chdir=terraform/modules/vault/root_ca_generation init
terraform -chdir=terraform/modules/vault/root_ca_generation apply -auto-approve \
  -var-file="$(pwd)/terraform/environments/dev/terraform.tfvars"

echo "==> Generating Intermediate CA..."
terraform -chdir=terraform/modules/vault/intermediate_ca_generation init
terraform -chdir=terraform/modules/vault/intermediate_ca_generation apply -auto-approve \
  -var-file="$(pwd)/terraform/environments/dev/terraform.tfvars"

echo "==> Generating Node Certificates..."
terraform -chdir=terraform/modules/vault/bootstrap init
terraform -chdir=terraform/modules/vault/bootstrap apply -auto-approve \
  -var-file="$(pwd)/terraform/environments/dev/terraform.tfvars"

echo "==> Starting Vault-1 (Leader)..."
docker compose -f overlays/dev/docker-compose.yaml up vault-1 --build --detach

echo "  -> Initializing Vault-1 and saving keys..."
mkdir -p ./hashicorp-vault-keys
docker exec vault-1 vault operator init -format=json > ./hashicorp-vault-keys/vault-init.json

echo "  -> Unsealing Vault-1..."
for token in $(cat ./hashicorp-vault-keys/vault-init.json | jq -r '.unseal_keys_b64[0:3] | join(" ")') ; do
  docker exec vault-1 vault operator unseal $token
done

echo "==> Starting Vault-2..."
docker compose -f overlays/dev/docker-compose.yaml up vault-2 --build --detach

echo "  -> Unsealing Vault-2..."
for token in $(cat ./hashicorp-vault-keys/vault-init.json | jq -r '.unseal_keys_b64[0:3] | join(" ")') ; do
  docker exec vault-2 vault operator unseal $token
done

echo "==> Starting Vault-3..."
docker compose -f overlays/dev/docker-compose.yaml up vault-3 --build --detach

echo "  -> Unsealing Vault-3..."
for token in $(cat ./hashicorp-vault-keys/vault-init.json | jq -r '.unseal_keys_b64[0:3] | join(" ")') ; do
    docker exec vault-3 vault operator unseal $token
done

echo "==> Cluster deployment and unseal completed successfully!"