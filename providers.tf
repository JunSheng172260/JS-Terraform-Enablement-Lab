terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  shared_config_files      = ["/Users/ecloudvalley/.aws/config"]
  shared_credentials_files = ["/Users/ecloudvalley/.aws/credentials"]
  profile                  = "default"
}
