resource "aws_dynamodb_table" "notes" {
  name           = "notes"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "users_email"

  attribute {
    name = "users_email"
    type = "S"
  }
}
