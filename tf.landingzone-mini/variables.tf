variable "default_region" {
  type        = string
  description = "기본 리전"
  default     = "ap-northeast-2"
}

# 환경별 파라미터: 워크스페이스(dev/stage/prod)로 선택
variable "envs" {
  description = "환경 매트릭스 (워크스페이스명 기준)"
  type = map(object({
    cidr_block   = string
    az_count     = number
    public_cidrs = number # 공개서브넷 개수(=AZ 수와 보통 동일)
    private_cidrs = number
    tags         = map(string)
    services = map(object({
      ports   = list(number) # 오픈할 포트
      cidrs   = list(string) # 허용 소스 CIDR
      egress  = bool         # 아웃바운드 열기 여부
    }))
  }))
}

# 예시 값: envs.tfvars.example 참고
