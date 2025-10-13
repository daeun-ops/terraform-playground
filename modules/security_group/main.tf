############################################
# 입력 변수: 블로그 글에서 다룬 타입들 샘플
############################################
variable "list_sample" {
  description = "list 예시"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "map_sample" {
  description = "map 예시"
  type        = map(string)
  default     = {
    a = "alpha"
    b = "bravo"
    c = "charlie"
  }
}

variable "users" {
  description = "관리자 여부가 있는 사용자 맵"
  type = map(object({
    is_admin = bool
  }))
  default = {
    alice = { is_admin = true  }
    bob   = { is_admin = false }
    cara  = { is_admin = true  }
  }
}

############################################
# 1) [] / {} 괄호에 따른 출력 타입 차이
#   - [] : tuple/list
#   - {} : object/map (key => value 형태 필요)
############################################

# list의 각 원소를 대문자로 변환 - [] 이므로 tuple 출력
locals {
  list_to_upper_tuple = [for k in var.list_sample : upper(k)]
}

# list를 object로 변환 - {} 이므로 object(map) 출력
locals {
  list_to_object_upper = { for k in var.list_sample : k => upper(k) }
}

output "ex1_list_to_upper_tuple" {
  description = "['a','b','c'] -> ['A','B','C'] (tuple)"
  value       = local.list_to_upper_tuple
}

output "ex2_list_to_object_upper" {
  description = "{ a='A', b='B', c='C' } (object/map)"
  value       = local.list_to_object_upper
}

############################################
# 2) key/value 둘 다 사용하는 for 표현식
#   - [for k, v in var.map_sample : length(k) + length(v)]
############################################
locals {
  map_key_value_lengths = [for k, v in var.map_sample : length(k) + length(v)]
}

output "ex3_map_key_value_lengths" {
  description = "map의 key와 value 길이 합 리스트"
  value       = local.map_key_value_lengths
}

############################################
# 3) 필터링 (if 절)
#   - 관리자만 / 일반 유저만 필터링
############################################
locals {
  admin_users = {
    for name, user in var.users : name => user
    if user.is_admin
  }

  regular_users = {
    for name, user in var.users : name => user
    if !user.is_admin
  }
}

output "ex4_admin_users" {
  description = "관리자만 남긴 map"
  value       = local.admin_users
}

output "ex5_regular_users" {
  description = "일반 유저만 남긴 map"
  value       = local.regular_users
}

############################################
# 4) 정렬 주의
#   - set/map/object는 내부적으로 정렬이 개입될 수 있음
#   - 문자열 set은 사전순 정렬, 기타 set은 임의 순서 가능
#   - 필요하면 toset() 등으로 명시 변환 후 사용 권장
############################################
# 문자열 set을 만들어 for로 변환 (사전순 정렬이 개입될 수 있음)
locals {
  string_set_sorted = toset(["delta", "alpha", "charlie", "bravo"])
  upper_from_set    = [for e in local.string_set_sorted : upper(e)]
}

output "ex6_upper_from_string_set" {
  description = "문자열 set -> 대문자 리스트 (사전순 정렬 영향 가능)"
  value       = local.upper_from_set
}

# 기타 타입 set 예시: 임의 순서 주의(데모를 위해 단순 구조 유지)
# 실제 인프라 의존 로직에서 순서 기대하지 말 것
locals {
  number_set = toset([10, 2, 33, 4])
  number_set_times_two = [for n in local.number_set : n * 2]
}

output "ex7_number_set_times_two" {
  description = "숫자 set -> 2배 리스트 (임의 순서일 수 있음)"
  value       = local.number_set_times_two
}
