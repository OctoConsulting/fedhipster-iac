resource "aws_iam_role" "sagemaker_deploy_lambda_role" {
  name = "sagemaker_deploy-lambda-role1"

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
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "sagemaker_deploy_lambda" {
  role       = aws_iam_role.sagemaker_deploy_lambda_role.name
  policy_arn = aws_iam_policy.sagemaker_deploy_lambda_policy.arn
}

resource "aws_iam_policy" "sagemaker_deploy_lambda_policy" {
  name        = "sagemaker_deploy-lambda-policy1"
  description = "Policy for the sagemaker function to put records into the Amazon Kinesis Data Firehose"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": [
                "arn:aws:sagemaker:*:*:endpoint/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource":  [
                "*"
            ]
        }
    ]
}
EOF

}

