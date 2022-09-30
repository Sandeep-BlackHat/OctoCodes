terraform {
  backend "http" {
    address = "http://localhost:8000/states/omni_tools"
    username = "Admin"
    password = "password"
    lock_address = "http://localhost:8000/states/omni_tools/lock/"
    unlock_address = "http://localhost:8000/states/omni_tools/unlock/"
  }
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
  }
}
provider "local" {}
resource "local_file" "hello" {
  content = "Hello Sudakar's team"
  filename = "omni_tools.txt"
}
