# providers.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1" # 東京リージョン

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "resource-management-app"
      ManagedBy   = "Terraform"
    }
  }
}