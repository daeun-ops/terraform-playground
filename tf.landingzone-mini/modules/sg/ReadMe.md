# tf-landingzone-mini (Data-Driven Multi-Env)

워크스페이스(dev/stage/prod) 전환만으로 VPC/서브넷/라우팅/보안그룹을
데이터 맵에서 **자동 생성**하는 미니 랜딩존 예제입니다.

## Highlights
- **for 표현식**으로 AZ/서브넷/CIDR/포트 규칙을 데이터 → 리소스로 변환
- **dynamic 블록**으로 SG 규칙(포트×CIDR) 2중루프 전개
- **workspace 기반** 환경 스위칭(dev/stage/prod)
- **map/object 변환**과 `flatten`, `cidrsubnet` 테크닉
- Tag 일관화, 요약 출력

## 빠른 시작
```bash
# 1) AWS 자격 증명 (profile/환경변수 등) 준비
export AWS_PROFILE=default

# 2) init
terraform init

# 3) 워크스페이스 생성/선택
terraform workspace new dev || true
terraform workspace select dev

# 4) 변수 주입(예시 파일 참고)
terraform plan -var-file="envs.tfvars.example"

# 실제 생성은 비용 발생 가능!
# terraform apply -var-file="envs.tfvars.example"
