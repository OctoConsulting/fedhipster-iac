  provider "aws" {
    region = "us-east-1"
  }
 
 module "terraform_state_backend" {
   source        = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
   namespace     = "eg"
   stage         = "app"
   name          = "tfbackend"
   attributes    = ["state"]
   region        = "us-east-1"
   force_destroy = true
 }