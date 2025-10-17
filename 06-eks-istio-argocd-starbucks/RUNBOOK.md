# 장애대읕 시나리오 적으라는데 난 ..... 아직 ㅠㅠ 아래까지는 완료 추후 더더ㅓ 추가해야함 장애시나리오

# Oncall Runbook – Starbucks Prod (Asia/Seoul)

## Severity
- Sev1: 결제/주문 전면 중단, 또는 API 5xx > 10% 10분 이상
- Sev2: API p95 > 800ms 30분 이상, 주문량 < 50% baseline 20분 이상
- Sev3: 단일 기능 퇴화(검색, 추천 등)

## Initial triage
1) 대시보드 열기 (Grafana → Folder: Starbucks)  
2) Rollouts 상태: `kubectl argo rollouts get rollout api -n prod`  
3) 최근 릴리즈? `argocd app history starbucks`  
4) 외부경로(blackbox) 상태: 패널/알람 확인

## Fast Burn 대응 (Sev1)
- 배포 동결: `argocd app sync starbucks --async=false --dry-run` (또는 Suspend)
- 롤아웃 중이면 Abort: `kubectl argo rollouts abort api -n prod`
- 즉시 롤백: `kubectl argo rollouts promote --to-stable api -n prod`
- 회복력 토글: Istio VS timeout 3s → 1.5s, retry 2→1 (values 파일 패치)
- 증거수집: 파드/노드 이벤트, HPA 이벤트, 큐 길이, 5xx Heatmap

## Slow Burn 대응 (Sev2)
- canary vs stable 비교
- 의존성(결제/주문/카트) fanout 분리 지표 확인
- 스케일업(HPA/KEDA) 한시 조정

## Escalation
- Slack #oncall @SRE-oncall
- PagerDuty 서비스: Starbucks-Prod
- 사업부 알림: #commerce-incident

## Postmortem
- 48시간 내 회고 작성 (5 Whys, 액션 아이템/DRI/ETA)
