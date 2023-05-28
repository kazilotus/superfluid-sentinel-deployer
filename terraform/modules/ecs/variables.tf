variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "family_name" {
  description = "The name of the ECS task definition family"
  type        = string
}

variable "image" {
  description = "The ECR URL image to deploy"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs where the ECS task can be launched"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the ECS task"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the IAM role for the ECS task execution"
  type        = string
}

variable "region" {
  description = "The AWS region in which to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "The CPU units to allocate for the ECS task"
  type        = string
}

variable "memory" {
  description = "The memory to allocate for the ECS task"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables in key-value format"
  type        = map(string)
}