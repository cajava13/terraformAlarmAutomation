# main.tf

#########################################
# main
#########################################
terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9.0"
    }
  }
}


