variable "vpc_id"      { type = string }
variable "services" {
  description = "서비스별 인바운드/아웃바운드 정책"
  type = map(object({
    ports  = list(number)
    cidrs  = list(string)
    egress = bool
  }))
}
variable "common_tags" { type = map(string) }
