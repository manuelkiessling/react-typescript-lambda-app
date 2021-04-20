resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend"
  force_destroy = "false"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  acl           = "public-read"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket" "backend_rest_apis" {
  bucket        = "${var.project_name}-backend-rest-apis"
  force_destroy = "false"
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "backend_rest_apis" {
  bucket = aws_s3_bucket.backend_rest_apis.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "backend_dynamodb_workers" {
  bucket        = "${var.project_name}-backend-dynamodb-workers"
  force_destroy = "false"
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "backend_dynamodb_workers" {
  bucket = aws_s3_bucket.backend_dynamodb_workers.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
