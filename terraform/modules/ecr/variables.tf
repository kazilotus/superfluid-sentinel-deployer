variable "repository_name" {}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
