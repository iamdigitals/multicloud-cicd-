resource "aws_kms_key" "main" {
  description         = "Customer-managed key for ${var.project_name} — encrypts ECR, CloudWatch logs, and SNS"
  enable_key_rotation = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}"
  target_key_id = aws_kms_key.main.key_id
}
