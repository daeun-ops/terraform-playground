# GameDay Scenarios (Quarterly)
- API 5xx 급증 (canary 이미지에 의도적 오류)
- 외부 결제 지연(3rd party latency 2s 삽입) → 타임아웃/재시도 확인
- SQS 큐 폭주 → KEDA 확장/회복 확인
- 노드 장애(특정 AZ cordon/drain) → PDB/Spread 효과 검증

