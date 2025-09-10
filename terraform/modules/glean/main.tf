




resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets_access" {
  name = "${var.name}-lambda-secrets-access"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = [
          data.aws_secretsmanager_secret.client_key.arn,
          data.aws_secretsmanager_secret.index_key.arn
        ]
      }
    ]
  })
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip3 install -r ${local.lambda_root}/requirements.txt -t ${local.lambda_root}/"
  }

  triggers = {
    dependencies_versions = filemd5("${local.lambda_root}/requirements.txt")
    source_index_version = filemd5("${local.lambda_root}/glean_lambda.py")
    source_setup_version = filemd5("${local.lambda_root}/setup.py")
  }
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_root, "glean_lambda.py"),
      fileset(local.lambda_root, "requirements.txt")
    ) :
    filename => filemd5("${local.lambda_root}/${filename}")
  }
}

data "archive_file" "lambda_source" {
  depends_on = [null_resource.install_dependencies]
  type             = "zip"
  source_dir       = local.lambda_root
  output_path      = "${path.module}/${random_uuid.lambda_src_hash.result}.zip"
  output_file_mode = "0644"
  excludes = [
    "**/.terragrunt-source-manifest",
    "**/__pycache__/**",
    "venv",
    "tests",
    "test_lambda.py",
    "test_data.py",
  ]
}
resource "aws_lambda_function" "cloud_glean" {
  depends_on = [data.archive_file.lambda_source]
  filename         = data.archive_file.lambda_source.output_path
  function_name    = "${var.prefix}-glean"
  source_code_hash = data.archive_file.lambda_source.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "glean_lambda.handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 1024
  logging_config {
    log_format = "JSON"
  }


  environment {
    variables = {
      GLEAN_ROLES_PREFIX       = "${var.tags.environment}-glean"
      LOGGING_LEVEL             = var.lambda_logging_level
      CLIENT_KEY_SECRET_ARN = data.aws_secretsmanager_secret.client_key.arn,
      INDEX_KEY_SECRET_ARN  = data.aws_secretsmanager_secret.index_key.arn,
    }
  }
}