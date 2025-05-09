provider "aws" {
  region = "us-east-1" # Adjust the region as needed
}

resource "aws_s3_bucket" "report_bucket" {
  bucket = var.report_bucket_name
}

resource "aws_dynamodb_table" "report_table" {
  name           = "report"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "get_report_lambda" {
  function_name = "GetReportLambda"
  runtime       = "java21"
  handler       = "com.example.lambda.GetReport::handleRequest"
  timeout       = 15
  memory_size   = 512
  architecture  = "arm64"
  s3_bucket     = var.function_bucket_name
  s3_key        = var.get_report_key
  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.report_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "create_report_lambda" {
  function_name = "CreateReportLambda"
  runtime       = "java21"
  handler       = "com.example.lambda.CreateReport::handleRequest"
  timeout       = 15
  memory_size   = 512
  architecture  = "arm64"
  s3_bucket     = var.function_bucket_name
  s3_key        = var.create_report_key
  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.report_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "fill_report_lambda" {
  function_name = "FillReportLambda"
  runtime       = "java21"
  handler       = "com.example.lambda.FillReport::handleRequest"
  timeout       = 15
  memory_size   = 512
  architecture  = "arm64"
  s3_bucket     = var.function_bucket_name
  s3_key        = var.fill_report_key
  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.report_bucket.bucket
    }
  }
}

resource "aws_api_gateway_rest_api" "report_api" {
  name        = "ReportApi"
  description = "API for report operations"
}

resource "aws_api_gateway_resource" "get_report" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  parent_id   = aws_api_gateway_rest_api.report_api.root_resource_id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_report_method" {
  rest_api_id   = aws_api_gateway_rest_api.report_api.id
  resource_id   = aws_api_gateway_resource.get_report.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_report_integration" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  resource_id = aws_api_gateway_resource.get_report.id
  http_method = aws_api_gateway_method.get_report_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_report_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "create_report" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  parent_id   = aws_api_gateway_rest_api.report_api.root_resource_id
  path_part   = ""
}

resource "aws_api_gateway_method" "create_report_method" {
  rest_api_id   = aws_api_gateway_rest_api.report_api.id
  resource_id   = aws_api_gateway_resource.create_report.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_report_integration" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  resource_id = aws_api_gateway_resource.create_report.id
  http_method = aws_api_gateway_method.create_report_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_report_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "fill_report" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  parent_id   = aws_api_gateway_rest_api.report_api.root_resource_id
  path_part   = "fill/{id}"
}

resource "aws_api_gateway_method" "fill_report_method" {
  rest_api_id   = aws_api_gateway_rest_api.report_api.id
  resource_id   = aws_api_gateway_resource.fill_report.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fill_report_integration" {
  rest_api_id = aws_api_gateway_rest_api.report_api.id
  resource_id = aws_api_gateway_resource.fill_report.id
  http_method = aws_api_gateway_method.fill_report_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fill_report_lambda.invoke_arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

variable "report_bucket_name" {
  type        = string
  description = "The name of the S3 bucket containing reports"
  default     = "report"
}

variable "function_bucket_name" {
  type        = string
  description = "The name of the S3 bucket containing the Lambda function"
  default     = "lambda"
}

variable "get_report_key" {
  type        = string
  description = "The S3 key (file name) of the GetReport Lambda function"
  default     = "GetReport"
}

variable "create_report_key" {
  type        = string
  description = "The S3 key (file name) of the CreateReport Lambda function"
  default     = "CreateReport"
}

variable "fill_report_key" {
  type        = string
  description = "The S3 key (file name) of the FillReport Lambda function"
  default     = "FillReport"
}
