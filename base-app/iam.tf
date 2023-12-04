data "aws_iam_policy_document" "ghost_app_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "ssm:GetParameter*",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"

    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ghost_app_policy" {
  name        = "ghost_app_policy"
  description = "Policy for Ghost Application"
  policy      = data.aws_iam_policy_document.ghost_app_policy_doc.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ghost_app_role" {
  name               = "ghost_app"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  #managed_policy_arns = [aws_iam_policy.ghost_app_policy.arn, ]
}

resource "aws_iam_role_policy_attachment" "ghost_app_policy_attach" {
  role       = aws_iam_role.ghost_app_role.name
  policy_arn = aws_iam_policy.ghost_app_policy.arn
}

resource "aws_iam_instance_profile" "ghost_app_profile" {
  name = "ghost_app"
  role = aws_iam_role.ghost_app_role.name
}


data "aws_iam_policy_document" "ghost_ecs_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ssm:GetParameter*",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:BatchImportUpstreamImage",

    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ghost_ecs_policy" {
  name        = "ghost_ecs_policy"
  description = "Policy for Ghost ECS Application"
  policy      = data.aws_iam_policy_document.ghost_ecs_policy_doc.json
}

resource "aws_iam_role" "ghost_ecs" {
  name = "ghost_ecs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ghost_ecs_policy_attach" {
  role       = aws_iam_role.ghost_ecs.name
  policy_arn = aws_iam_policy.ghost_ecs_policy.arn
}

resource "aws_iam_instance_profile" "ghost_ecs_profile" {
  name = "ghost_ecs_instance_profile"
  role = aws_iam_role.ghost_ecs.name
}

# resource "aws_iam_role" "ghost_app_role" {
#   name               = "ghost_app"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }



# resource "aws_iam_policy" "ghost_app_policy" {
#   name        = "ghost_app_policy"
#   description = "Policy for Ghost Application"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = [
#           "ec2:Describe*",
#           "elasticfilesystem:DescribeFileSystems",
#           "elasticfilesystem:ClientMount",
#           "elasticfilesystem:ClientWrite"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
