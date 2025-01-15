terraform {
  backend "s3" {
    bucket       = "v-ris-terraform"
    key          = "barebone/state"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
