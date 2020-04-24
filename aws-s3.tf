resource "aws_kms_key" "dev_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "stage_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "prod_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "app-dev" {
  bucket = "app-dev-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.dev_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "App dev bucket"
    Environment = "dev"
  }

  force_destroy = true
}

resource "aws_s3_bucket" "app-stage" {
  bucket = "app-stage-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.stage_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "App stage bucket"
    Environment = "stage"
  }

  force_destroy = true
}

resource "aws_s3_bucket" "app-prod" {
  bucket = "app-prod-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  acl    = "private"

    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.prod_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

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
