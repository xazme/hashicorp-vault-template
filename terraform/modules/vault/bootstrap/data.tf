data "terraform_remote_state" "intermediate_ca_generation" {
  backend = "local"

  config = {
    path = "../intermediate_ca_generation/terraform.tfstate"
  }
}
