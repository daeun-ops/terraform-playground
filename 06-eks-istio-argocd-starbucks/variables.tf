variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  description = "EKS cluster name (already created)"
  type        = string
  default     = "starbucks-eks"
}
