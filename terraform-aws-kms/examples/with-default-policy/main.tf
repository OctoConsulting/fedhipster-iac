provider "aws" {
  region = "us-east-2"
}

module "cmk_key" {
  source = "../../"

  product_domain          = "retro-spider"
  alias_name              = "rs-key"
  environment             = "production"
  description             = "Key to encrypt and decrypt secret parameters"
  deletion_window_in_days = 7
}
