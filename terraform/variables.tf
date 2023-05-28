variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tf_bucket_name" {
  description = "The name of the S3 bucket used for storing Terraform state"
  type        = string
  default     = "tf-state-bucket"
}

variable "tf_table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "tf-lock-table"
}

variable "image_tag" {
  description = "The Docker image tag"
  type        = string
  default     = "latest"
}

variable "cpu" {
  description = "The CPU units to allocate for the ECS task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "The memory to allocate for the ECS task"
  type        = string
  default     = "512"
}

variable "sentinel_env" {
  description = "The environment variables for the Sentinel application"
  type        = string
  default     = "{\"HTTP_RPC_NODE\":\"https://polygon-rpc.com\"}"
}