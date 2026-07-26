data "aws_caller_identity" "current_account" {}

resource "aws_iam_openid_connect_provider" "github_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "role_github_actions" {
  name = "github-actions-infra-likert"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:helen-silv4/infra-likert:ref:refs/heads/main",
              "repo:helen-silv4/infra-likert:pull_request"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policy_pipeline" {
  name = "infra-likert-pipeline-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AccessBucketState"
      Effect   = "Allow"
      Action   = ["s3:ListBucket"]
      Resource = "arn:aws:s3:::infra-likert-tfstate"
      },
      {
        Sid    = "AccessObjectState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::infra-likert-tfstate/*"
      },
      {
        Sid    = "DynamoDBTables"
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:DescribeKinesisStreamingDestination",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:ListTagsOfResource"
        ]
        Resource = [
          "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current_account.account_id}:table/tb_usuarios",
          "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current_account.account_id}:table/tb_avaliacoes"
        ]
      },
      {
        Sid    = "IamReadOnly"
        Effect = "Allow"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ]
        Resource = [
          aws_iam_openid_connect_provider.github_provider.arn,
          aws_iam_role.role_github_actions.arn,
          "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:policy/infra-likert-pipeline-policy"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_policy_annex" {
  role       = aws_iam_role.role_github_actions.name
  policy_arn = aws_iam_policy.policy_pipeline.arn
}
