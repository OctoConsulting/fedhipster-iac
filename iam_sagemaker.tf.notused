resource "aws_iam_role" "AmazonSageMaker-ExecutionRole-20190810T140957" {
  name = "AmazonSageMaker-ExecutionRole-20190810T140957"
  path = "/service-role/"


  tags = {
    Group     = var.default_resource_group
    CreatedBy = var.default_created_by
  }

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF


  #tags = {
    #Group     = var.default_resource_group
    #CreatedBy = var.default_created_by
  #}
}

resource "aws_iam_role_policy_attachment" "AmazonSageMaker-ExecutionRole-20190810T140957" {
  role       = "${aws_iam_role.AmazonSageMaker-ExecutionRole-20190810T140957.name}"
  policy_arn = "${aws_iam_policy.AmazonSageMaker-ExecutionPolicy-20190810T140957.arn}"
}


resource "aws_iam_policy" "AmazonSageMaker-ExecutionPolicy-20190810T140957" {
  name        = "AmazonSageMaker-ExecutionPolicy-20190810T140957"
  description = "Policy for the Notebook Instance to manage training jobs, models and endpoints"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "secretsmanager:ResourceTag/SageMaker": "true"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "*",
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "s3:ExistingObjectTag/SageMaker": "true"
                }
            }
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/sagemaker.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_SageMakerEndpoint",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "sagemaker.application-autoscaling.amazonaws.com"
                }
            }
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "robomaker.amazonaws.com"
                }
            }
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "sagemaker.amazonaws.com",
                        "glue.amazonaws.com",
                        "robomaker.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:DeleteAlarms",
                "cognito-idp:AdminCreateUser",
                "ec2:CreateNetworkInterfacePermission",
                "glue:GetJobRun",
                "s3:DeleteObject",
                "glue:GetJobs",
                "lambda:ListFunctions",
                "ecr:GetAuthorizationToken",
                "application-autoscaling:DeleteScalingPolicy",
                "cloudwatch:GetMetricStatistics",
                "ec2:CreateNetworkInterface",
                "s3:PutObject",
                "robomaker:CreateSimulationApplication",
                "cognito-idp:CreateUserPoolClient",
                "application-autoscaling:DescribeScalingPolicies",
                "cloudwatch:DescribeAlarms",
                "ec2:DescribeSubnets",
                "secretsmanager:ListSecrets",
                "cognito-idp:ListUsers",
                "cognito-idp:CreateGroup",
                "cognito-idp:CreateUserPool",
                "sns:ListTopics",
                "s3:ListBucket",
                "codecommit:CreateRepository",
                "cognito-idp:AdminAddUserToGroup",
                "glue:DeleteJob",
                "cloudwatch:ListMetrics",
                "codecommit:ListRepositories",
                "glue:CreateJob",
                "cognito-idp:CreateUserPoolDomain",
                "cognito-idp:ListGroups",
                "glue:ResetJobBookmark",
                "cognito-idp:AdminDeleteUser",
                "aws-marketplace:ViewSubscriptions",
                "codecommit:ListBranches",
                "iam:ListRoles",
                "codecommit:BatchGetRepositories",
                "elastic-inference:Connect",
                "ec2:DescribeSecurityGroups",
                "s3:ListAllMyBuckets",
                "ec2:DescribeVpcs",
                "kms:ListAliases",
                "glue:GetJobRuns",
                "ecr:Describe*",
                "cognito-idp:ListIdentityProviders",
                "s3:CreateBucket",
                "cognito-idp:ListUsersInGroup",
                "cognito-idp:DescribeUserPool",
                "logs:CreateLogStream",
                "logs:GetLogEvents",
                "cognito-idp:AdminDisableUser",
                "cognito-idp:AdminRemoveUserFromGroup",
                "application-autoscaling:PutScheduledAction",
                "ec2:DescribeRouteTables",
                "ecr:BatchCheckLayerAvailability",
                "application-autoscaling:RegisterScalableTarget",
                "lambda:InvokeFunction",
                "ecr:CreateRepository",
                "robomaker:DescribeSimulationApplication",
                "ecr:GetDownloadUrlForLayer",
                "ec2:DeleteNetworkInterface",
                "cognito-idp:UpdateUserPoolClient",
                "cognito-idp:ListUserPools",
                "logs:CreateLogGroup",
                "robomaker:DescribeSimulationJob",
                "groundtruthlabeling:*",
                "s3:GetObject",
                "codecommit:GetRepository",
                "glue:StartJobRun",
                "application-autoscaling:PutScalingPolicy",
                "ecr:BatchGetImage",
                "ec2:DescribeVpcEndpoints",
                "glue:GetJob",
                "cloudwatch:GetMetricData",
                "application-autoscaling:DeleteScheduledAction",
                "logs:DescribeLogStreams",
                "ec2:DescribeDhcpOptions",
                "cognito-idp:ListUserPoolClients",
                "robomaker:CreateSimulationJob",
                "cognito-idp:AdminEnableUser",
                "ec2:DeleteNetworkInterfacePermission",
                "ec2:DescribeNetworkInterfaces",
                "application-autoscaling:DescribeScalingActivities",
                "sagemaker:*",
                "kms:DescribeKey",
                "glue:UpdateJob",
                "cognito-idp:DescribeUserPoolClient",
                "robomaker:DeleteSimulationApplication",
                "application-autoscaling:DescribeScalableTargets",
                "robomaker:CancelSimulationJob",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricAlarm",
                "ec2:CreateVpcEndpoint",
                "application-autoscaling:DescribeScheduledActions",
                "cognito-idp:UpdateUserPool",
                "s3:GetBucketLocation",
                "application-autoscaling:DeregisterScalableTarget"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "sns:CreateTopic",
                "codecommit:GitPull",
                "ecr:BatchDeleteImage",
                "ecr:UploadLayerPart",
                "ecr:DeleteRepository",
                "ecr:PutImage",
                "secretsmanager:GetSecretValue",
                "ecr:SetRepositoryPolicy",
                "ecr:CompleteLayerUpload",
                "sns:Subscribe",
                "ecr:DeleteRepositoryPolicy",
                "ecr:InitiateLayerUpload",
                "codecommit:GitPush"
            ],
            "Resource": [
                "arn:aws:ecr:*:*:repository/*sagemaker*",
                "arn:aws:secretsmanager:*:*:secret:AmazonSageMaker-*",
                "arn:aws:sns:*:*:*SageMaker*",
                "arn:aws:sns:*:*:*Sagemaker*",
                "arn:aws:sns:*:*:*sagemaker*",
                "arn:aws:codecommit:*:*:*sagemaker*",
                "arn:aws:codecommit:*:*:*SageMaker*",
                "arn:aws:codecommit:*:*:*Sagemaker*"
            ]
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": "secretsmanager:CreateSecret",
            "Resource": "arn:aws:secretsmanager:*:*:secret:AmazonSageMaker-*"
        }
    ]
}
EOF
}



