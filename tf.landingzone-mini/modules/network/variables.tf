variable "env_name"      { type = string }
variable "cidr_block"    { type = string }
variable "az_count"      { type = number }
variable "public_count"  { type = number }
variable "private_count" { type = number }
variable "tags"          { type = map(string) }
