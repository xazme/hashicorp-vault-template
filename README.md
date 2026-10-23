# HashiCorp Vault HA Cluster in Docker

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Vault](https://img.shields.io/badge/Vault-000000?style=for-the-badge&logo=hashicorpvault&logoColor=white)

A 3-node HashiCorp Vault cluster running in Docker Compose with Raft Integrated Storage and strict mTLS. 

Unlike typical `-dev` mode setups, this repository configures a proper Chain of Trust. Certificates are generated via Terraform using a Root CA -> Intermediate CA hierarchy to isolate the root private key.

## Architecture & Chain of Trust
```text
 ┌───────────────────────┐
 │       Root CA         │  <-- Self-signed (max_path_length = 1)
 └──────────┬────────────┘
            │ signs
            ▼
 ┌───────────────────────┐
 │   Intermediate CA     │  <-- Signed by Root CA (max_path_length = 0)
 └──────────┬────────────┘
            │ signs
            ▼
 ┌───────────────────────┐
 │ Vault Nodes (1, 2, 3) │  <-- End-Entity Certificates for mTLS
 └───────────────────────┘
```
## Key Features
* **Raft Storage Backend:** Persistent storage with high availability.
* **Strict mTLS:** Nodes require and verify client certificates.
* **GitOps Structure:** Configurations separated into `base` and `overlays`.
* **Automated Bootstrap:** Bash script to generate PKI, initialize the cluster, and auto-unseal nodes.
## Quick Start
**1. Clone the repository**
```bash
git clone --branch high-availability-cluster https://github.com/xazme/hashicorp-vault-template
cd hashicorp-vault-template
```
**2. Configure Terraform Variables**
Copy the provided example variables file to set up your local configuration. You can adjust the values inside if needed.
```bash
cp terraform/environments/dev/terraform.tfvars_example terraform/environments/dev/terraform.tfvars
```
**3. Run the deployment script**
This script will create volumes, generate PKI certificates via Terraform, and start the Docker containers.
```bash
sh deploy.sh
```
**4. Access the Cluster**
* Vault API is exposed at `https://127.0.0.1:8200`.
* The root token and unseal keys are automatically saved to `./hashicorp-vault-keys/vault-init.json`.


## Cleanup
To destroy the cluster and remove generated certificates:
```bash
docker compose -f overlays/dev/infrastructure/docker-compose.yaml down -v
rm -rf overlays/dev/infrastructure/vault/certs/*
rm -rf hashicorp-vault-keys/
```
## Security Notes
* **Terraform State:** The local `.tfstate` files contain the Root CA private key in plaintext. This project uses local state for demonstration purposes. In production, use a secure remote backend (e.g., AWS S3, Consul).
* **Auto-Unseal:** Manual unseal via script is used to demonstrate mechanics. For production, configure Auto-Unseal with a cloud KMS.