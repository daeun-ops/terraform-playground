data "aws_availability_zones" "this" {
  state = "available"
}

# 사용할 AZ 목록 계산 (for 표현식으로 상위 N개만)
locals {
  az_names = [for i in range(var.az_count) : data.aws_availability_zones.this.names[i]]
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "${var.env_name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.env_name}-igw" })
}

# 서브넷 CIDR 자동 계산:
#   /16 -> public(/20 * public_count) + private(/20 * private_count)
#   cidrsubnet(cidr, newbits, netnum)
locals {
  public_indices  = range(var.public_count)
  private_indices = range(var.private_count)

  # 멋짐 포인트: map comprehension으로 "이름 => CIDR" 테이블 생성
  public_cidrs_by_az = {
    for idx, az in local.az_names :
    az => cidrsubnet(var.cidr_block, 4, idx) # /20
  }

  private_cidrs_by_az = {
    for idx, az in local.az_names :
    az => cidrsubnet(var.cidr_block, 4, idx + 16) # 다른 블록으로 오프셋
  }
}

# 공개/프라이빗 서브넷을 AZ마다 1개씩(예시): for_each + object 합성
resource "aws_subnet" "public" {
  for_each                = { for az, cidr in local.public_cidrs_by_az : az => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.env_name}-public-${each.key}" })
}

resource "aws_subnet" "private" {
  for_each          = { for az, cidr in local.private_cidrs_by_az : az => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(var.tags, { Name = "${var.env_name}-private-${each.key}" })
}

# 라우팅: 퍼블릭 라우트 테이블 + 0.0.0.0/0 -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.env_name}-public-rt" })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 퍼블릭 서브넷에 라우트 테이블 연결 (for_each)
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

output "vpc_id"             { value = aws_vpc.this.id }
output "az_names"           { value = local.az_names }
output "public_subnet_ids"  { value = [for s in aws_subnet.public  : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
