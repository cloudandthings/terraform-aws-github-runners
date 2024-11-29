data "aws_iam_policy_document" "secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:github-runner-example"
    ]
  }
}

resource "aws_iam_policy" "secrets_manager" {
  name   = "${var.source_name}-secrets-manager-policy"
  policy = data.aws_iam_policy_document.secrets_manager.json
}