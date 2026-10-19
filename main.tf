provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "automaster_bucket" {
  bucket = "automaster-site"
}

resource "aws_s3_bucket_website_configuration" "automaster_site" {
  bucket = aws_s3_bucket.automaster_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.automaster_bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "catalogo" {
  bucket       = aws_s3_bucket.automaster_bucket.id
  key          = "catalogo.html"
  source       = "${path.module}/catalogo.html"
  content_type = "text/html"
}

resource "aws_s3_object" "contacto" {
  bucket       = aws_s3_bucket.automaster_bucket.id
  key          = "contacto.html"
  source       = "${path.module}/contacto.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles" {
  bucket       = aws_s3_bucket.automaster_bucket.id
  key          = "styles.css"
  source       = "${path.module}/styles.css"
  content_type = "text/css"
}

output "website_url" {
  value = "http://localhost:4566/${aws_s3_bucket.automaster_bucket.id}/index.html"
}