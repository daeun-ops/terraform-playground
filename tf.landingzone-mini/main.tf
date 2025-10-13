############################################
# 워크스페이스 기반 환경 선택
############################################
locals {
  current_env_name = terraform.workspace != "default" ? terraform.workspace : "dev"
  current_env      = lookup(var.envs, local.current_env_name, var.envs["dev"])
  base_tags        = merge({ project = "tf-landingzone-mini" }, local.current_env.tags)
}

terraform {
  backend "local" {}
}

############################################
# 네트워크 모듈: VPC/서브넷/라우팅
############################################
module "network" {
  source        = "./modules/network"
  env_name      = local.current_env_name
  cidr_block    = local.current_env.cidr_block
  az_count      = local.current_env.az_count
  public_count  = local.current_env.public_cidrs
  private_count = local.current_env.private_cidrs
  tags          = local.base_tags
}

############################################
# 보안그룹 모듈: 서비스 맵 -> SG 세트
############################################
module "sg_set" {
  source     = "./modules/sg"
  vpc_id     = module.network.vpc_id
  services   = local.current_env.services
  common_tags = local.base_tags
}

############################################
# 멋짐 포인트: 데이터 기반 요약 출력
############################################
output "network_summary" {
  value = {
    env          = local.current_env_name
    vpc_cidr     = local.current_env.cidr_block
    azs          = module.network.az_names
    public_subnets  = module.network.public_subnet_ids
    private_subnets = module.network.private_subnet_ids
    security_groups = module.sg_set.sg_ids_by_service
  }
}
