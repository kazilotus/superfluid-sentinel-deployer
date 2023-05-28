variable "ecs_task_execution_role_name" {}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
