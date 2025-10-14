variable "fruits" {
  description = "Sample list"
  type        = list(string)
  default     = ["apple", "banana", "cherry", "banana"]
}

variable "codes" {
  description = "Story of Nania"
  type        = map(string)
  default = {
    a = "lucy"
    b = "biber"
    c = "howl"
  }
}

variable "users" {
  description = "User objects with roles"
  type = map(object({
    role  = string
    score = number
  }))
  default = {
    sophie = { role = "admin",  score = 91 }
    Edward   = { role = "viewer", score = 77 }
    Susan  = { role = "editor", score = 84 }
    Justin  = { role = "viewer", score = 60 }
  }
}
