terraform {
  backend "s3" {
    bucket       = "<YOUR-BUCKET-HERE>"
    key          = "<OBJECT-KEY>"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83.0"
    }
  }
}
