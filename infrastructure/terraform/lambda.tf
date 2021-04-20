resource "aws_iam_policy" "dynamodb_default" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:ListShards",
                "dynamodb:ListStreams"
            ],
            "Resource": [
                "${aws_dynamodb_table.users.arn}",
                "${aws_dynamodb_table.api_keys.arn}",
                "${aws_dynamodb_table.notes.arn}",
                "${aws_dynamodb_table.notes.arn}/stream/*",
                "${aws_dynamodb_table.wordcounts.arn}"
            ]
        }
    ]
}
EOF
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "rest_apis_default" {
  function_name = "rest_apis_default"

  s3_bucket = aws_s3_bucket.backend_rest_apis.bucket
  s3_key    = "${var.deployment_number}/rest_apis_default.zip"

  handler = "index.handler"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_rest_apis_default.arn
}

resource "aws_iam_role" "lambda_rest_apis_default" {
  name = "lambda_rest_apis_default"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_to_lambda_rest_apis_default" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role = aws_iam_role.lambda_rest_apis_default.name
}

resource "aws_lambda_permission" "rest_apis_default" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_apis_default.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.default.execution_arn}/*/*"
}



resource "aws_iam_role_policy_attachment" "dynamodb_default_to_lambda_rest_apis_default" {
  policy_arn = aws_iam_policy.dynamodb_default.arn
  role = aws_iam_role.lambda_rest_apis_default.name
}



resource "aws_lambda_function" "dynamodb_workers_wordcounter" {
  function_name = "dynamodb_workers_wordcounter"

  s3_bucket = aws_s3_bucket.backend_dynamodb_workers.bucket
  s3_key    = "${var.deployment_number}/dynamodb_workers_wordcounter.zip"

  handler = "index.handler"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_dynamodb_workers_wordcounter.arn
}

resource "aws_iam_role" "lambda_dynamodb_workers_wordcounter" {
  name = "lambda_dynamodb_workers_wordcounter"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_to_lambda_dynamodb_workers_wordcounter" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role = aws_iam_role.lambda_dynamodb_workers_wordcounter.name
}

resource "aws_iam_role_policy_attachment" "dynamodb_default_to_lambda_dynamodb_workers_wordcounter" {
  policy_arn = aws_iam_policy.dynamodb_default.arn
  role = aws_iam_role.lambda_dynamodb_workers_wordcounter.name
}

resource "aws_lambda_event_source_mapping" "lambda_dynamodb_workers_wordcounter" {
  event_source_arn  = aws_dynamodb_table.notes.stream_arn
  function_name     = aws_lambda_function.dynamodb_workers_wordcounter.arn
  starting_position = "LATEST"
}
