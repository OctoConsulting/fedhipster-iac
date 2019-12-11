variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "cluster-name" {
  default = "eks-cluster-app"
  type = "string"
}
# Default Tags
variable "default_resource_group" {
  description = "Default value to be used in resources' Group tag."
  default     = "sagemaker_deploy"
}

variable "default_created_by" {
  description = "Default value to be used in resources' CreatedBy tag."
  default     = "terraform"
}

variable "aws_profile" {
  default = "default"
}

# Parameters
variable "function_bucket_name" {
  description = "Name of the S3 bucket hosting the code for BlazingText Lambda function."
}

variable "function_version" {
  description = "Version of the BlazingText Lambda function to use."
}

variable "s3_bucket_name_1" {
  description = "New bucket for storing the Amazon SageMaker model and training data."
}

variable "s3_bucket_name_2" {
  description = "New bucket for storing processed events for visualization features."
}

variable "kinesis_firehose_prefix" {
  description = "Kinesis Firehose prefix for delivery of processed events."
  default     = "sagemaker_deploy/firehose/"
}
