data "terraform_remote_state" "root_ca_generation" {
  backend = "local"

  config = {
    path = "../root_ca_generation/terraform.tfstate"
  }
}
