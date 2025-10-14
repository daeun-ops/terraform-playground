variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "AWS region"
}

variable "eks_cluster_name" {
  type        = string
  default     = "ecommerce-eks"
}

variable "namespace" {
  type        = string
  default     = "ecommerce"
}

variable "services" {
  description = "E-commerce microservices and their IAM requirements"
  type = map(object({
    policy_template = string
    service_account = string
  }))

  default = {
    cart = {
      policy_template = "templates/policy-cart.json.tpl"
      service_account = "cart-sa"
    }
    order = {
      policy_template = "templates/policy-order.json.tpl"
      service_account = "order-sa"
    }
    payment = {
      policy_template = "templates/policy-payment.json.tpl"
      service_account = "payment-sa"
    }
  }
}
