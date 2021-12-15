variable "common_tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default     = {}
}

variable "tags_prefix" {
  description = "Common prefix to add to all tag names."
  type        = string
}

locals {
  common_tags = merge(var.common_tags, {
    "${var.tags_prefix}-terraform-module" = path.module
  })
}
