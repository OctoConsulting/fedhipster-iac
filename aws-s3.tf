
resource "aws_s3_bucket" "app-dev" {
  bucket = "app-dev-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

  tags = {
    Name        = "App dev bucket"
    Environment = "dev"
  }

  force_destroy = true
}

resource "aws_s3_bucket" "app-stage" {
  bucket = "app-stage-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

  tags = {
    Name        = "App stage bucket"
    Environment = "stage"
  }

  force_destroy = true
}

resource "aws_s3_bucket" "app-prod" {
  bucket = "app-prod-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

  tags = {
    Name        = "App prod bucket"
    Environment = "prod"
  }

  force_destroy = true
}

output "dev_bucket" {
  description = "Dev bucket"
  value       = "${aws_s3_bucket.app-dev.bucket}"
}

output "stage_bucket" {
  description = "Stage bucket"
  value       = "${aws_s3_bucket.app-stage.bucket}"
}

output "prod_bucket" {
  description = "Stage bucket"
  value       = "${aws_s3_bucket.app-prod.bucket}"
}
