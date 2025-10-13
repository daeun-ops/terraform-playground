# Terraform For Expression Examples

블로그 글 **「[Terraform] For문」**의 내용을 그대로 재현한 예시 코드입니다.  
- 입력 타입: list, map, object 등  
- `[]` / `{}` 괄호에 따른 출력 타입 차이  
- `if`를 사용한 필터링  
- set/map의 정렬 특성 주의점  

## 사용법
```bash
terraform init   # (필요시, providers 없어서 스킵해도 무방)
terraform apply  # 모든 예시는 output 으로 결과 확인 가능
