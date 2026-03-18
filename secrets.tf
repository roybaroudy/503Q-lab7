# ─── SSM Parameters ───
resource "aws_ssm_parameter" "db_password" {
  name  = "/lab007/db_password"
  type  = "SecureString"
  value = "supersecretpassword123"
  tags  = { Name = "lab007-db-password" }
}

resource "aws_ssm_parameter" "app_env" {
  name  = "/lab007/app_env"
  type  = "String"
  value = "production"
  tags  = { Name = "lab007-app-env" }
}

# ─── IAM Policy to read SSM parameters ───
resource "aws_iam_role_policy" "ssm_read" {
  name = "lab007-ssm-read"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      Resource = "arn:aws:ssm:*:*:parameter/lab007/*"
    }]
  })
}