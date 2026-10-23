terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker" }
    aws    = { source = "hashicorp/aws" }
  }
}

provider "docker" {}

# 1. Contenedor Floci (Mock de S3)
resource "docker_image" "floci" {
  name = "floci/floci:latest"
}

resource "docker_container" "floci" {
  name  = "floci"
  image = docker_image.floci.image_id
  ports {
    internal = 4566
    external = 4566
  }
}

# 2. Proveedor AWS apuntando a Floci
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints {
    s3 = "http://localhost:4566"
  }
}

# 3. Bucket S3 en Floci
resource "aws_s3_bucket" "b" {
  bucket     = "automaster"
  depends_on = [docker_container.floci]
}

resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "public-read"
}

# 4. Subida de archivos estáticos
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.b.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "catalogo" {
  bucket       = aws_s3_bucket.b.id
  key          = "catalogo.html"
  source       = "${path.module}/catalogo.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "contacto" {
  bucket       = aws_s3_bucket.b.id
  key          = "contacto.html"
  source       = "${path.module}/contacto.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.b.id
  key          = "css/style.css"
  source       = "${path.module}/css/style.css"
  content_type = "text/css"
  acl          = "public-read"
}

# Output para ver el sitio directo
output "website_url" {
  value = "http://localhost:4566/automaster/index.html"
}