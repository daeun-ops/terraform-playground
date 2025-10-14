###########################################################
# 1) [] vs {} : output 타입 차이 (list/tuple vs map/object)
###########################################################

# [] 사용 → list/tuple
locals {
  fruits_upper_list = [for f in var.fruits : upper(f)]
}

# {} 사용 → map/object (key 필요)
locals {
  fruits_len_map = { for f in var.fruits : f => length(f) }
}

output "ex1_fruits_upper_list" {
  description = "['apple','banana','cherry','banana'] -> upper(list)"
  value       = local.fruits_upper_list
}

output "ex2_fruits_len_map" {
  description = "fruit => length map"
  value       = local.fruits_len_map
}

###########################################################
# 2) map 반복에서 key, value 동시 사용
###########################################################
locals {
  code_key_value_lengths = [for k, v in var.codes : length(k) + length(v)]
  code_keys              = [for k, _ in var.codes : k]
  code_values            = [for _, v in var.codes : v]
}

output "ex3_code_key_value_lengths" {
  description = "sum(len(key), len(value))"
  value       = local.code_key_value_lengths
}
output "ex4_code_keys"   { value = local.code_keys }
output "ex5_code_values" { value = local.code_values }

###########################################################
# 3) 필터링(if) : 조건에 맞는 항목만 남기기
###########################################################
locals {
  users_admin_only = {
    for name, u in var.users : name => u
    if u.role == "admin"
  }

  users_highscore = {
    for name, u in var.users : name => u
    if u.score >= 80
  }
}

output "ex6_users_admin_only" { value = local.users_admin_only }
output "ex7_users_highscore"  { value = local.users_highscore  }

###########################################################
# 4) 정렬/중복 주의: set/map은 순서 X → 필요 시 정렬
###########################################################
locals {
  # 중복 제거(set) → 순서 보장 안 됨
  fruit_set           = toset(var.fruits)
  fruit_set_upper     = [for f in local.fruit_set : upper(f)]
  # 보여줄 때는 정렬된 list로 변환
  fruit_sorted_unique = sort(tolist(local.fruit_set))
}

output "ex8_fruit_set_upper" {
  description = "set 기반 upper(list) — 순서 비결정적"
  value       = local.fruit_set_upper
}

output "ex9_fruit_sorted_unique" {
  description = "중복 제거 + 정렬된 리스트"
  value       = local.fruit_sorted_unique
}

###########################################################
# 5) 키 정렬: map/object를 예쁘게 출력하고 싶을 때
###########################################################
locals {
  codes_sorted_pairs = [
    for k in sort(keys(var.codes)) : {
      key   = k
      value = var.codes[k]
    }
  ]
}

output "ex10_codes_sorted_pairs" {
  description = "map을 키 정렬 후 리스트로 변환"
  value       = local.codes_sorted_pairs
}

###########################################################
# 6) 2중 루프: 포트 × CIDR 조합(flatten)
###########################################################
locals {
  ports = [22, 80, 443]
  cidrs = ["10.0.0.0/24", "192.168.1.0/24"]

  port_cidr_pairs = flatten([
    for p in local.ports : [
      for c in local.cidrs : {
        port = p
        cidr = c
      }
    ]
  ])
}

output "ex11_port_cidr_pairs" {
  description = "Cartesian product: ports × cidrs"
  value       = local.port_cidr_pairs
}

###########################################################
# 7) group-by 패턴: 조건별로 묶기 (viewer/admin 등)
###########################################################
locals {
  users_group_by_role = {
    for role in distinct([for _, u in var.users : u.role]) :
    role => [
      for name, u in var.users : name
      if u.role == role
    ]
  }
}

output "ex12_users_group_by_role" {
  description = "역할(role)별 사용자 이름 그룹"
  value       = local.users_group_by_role
}

###########################################################
# 8) zip / zipmap / transpose : 형태 변환 테크닉
###########################################################
locals {
  # (예시) zipmap으로 key/value 리스트를 map으로
  klist = ["id", "name", "role"]
  vlist = ["u-001", "alice", "admin"]
  kvmap = zipmap(local.klist, local.vlist)

  # 리스트의 리스트 전치 (행<->열)
  matrix      = [["Sophie", "susan", "jusitn"], ["admin", "viewer", "editor"]]
  matrix_T    = transpose(local.matrix)
}

output "ex13_kvmap"   { value = local.kvmap }
output "ex14_matrix_T" { value = local.matrix_T }
