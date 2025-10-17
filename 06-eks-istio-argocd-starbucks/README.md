# Starbucks App Infra — EKS + Istio + Argo CD + Observability Stack

 “스타벅스 앱 서비스”를 가정한 **클라우드 인프라 + 관제 + 운영 자동화** same project입니다 
GitOps 흐름, 장애 대응, 로그·트레이스·지표 통합 등 실제 운영 환경 수준의 구성이라고 볼수...?

---

## 주요 구성

- **EKS 클러스터** 위에 Istio 서비스 메시 구축  
- **Argo CD (GitOps)**로 인프라 + 애플리케이션 배포 및 자동 동기화  
- **Prometheus** + **Grafana**를 통한 메트릭 수집 및 시각화  
- **Loki / Promtail** 로그 수집 및 검색  
- **Tempo / OpenTelemetry (OTel Collector)**을 통한 트레이스 수집  
- **Istio → OTel** 연동으로 서비스 호출 흐름 트레이싱 가능  
- **SLO 기반 알림** (fast burn / slow burn), 비즈니스 KPI 알람  
- **Argo Rollouts** + 카나리 분석 → 자동 롤백 가능  
- **KEDA 기반 스케일링**, **시크릿 접근 역할 분리**, **NetPol / PDB / 리밸런싱 정책** 등 생산환경 감성 추가  
- **Runbook / Change Freeze / GameDay 시나리오** 포함 — 이야깃거리까지 챙긴 구성  

---

## folder 내영

| 폴더 / 파일 | 설명 |
|--------------|------|
| `argocd/` | App-of-Apps, Istio, Observability, Starbucks 앱 등 GitOps 앱 정의 |
| `helm/` | Istio / Argo CD / 앱 차트의 기본 helm values |
| `monitoring/` or `observability/` | 로그/트레이스/알림 설정, Grafana datasource, OTEL 설정 등 |
| `starbucks-chart/` | 스타벅스 앱의 마이크로서비스 배포 정의 (api / order / payment / Istio 리소스) |
| `RUNBOOK.md`, `CHANGE_FREEZE.md`, `GAMEDAY.md` | 운영관제 및 장애대응 문서 |

---

## 사용법 (데모용) - 되려나....

```bash
# 1) Terraform / AWS credentials 설정
terraform init
terraform apply   # 비용 발생 주의!

# 2) Argo CD UI 접근
kubectl -n argocd port-forward svc/argocd-server 8080:80
# admin 비밀번호 획득:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

# 3) GitOps 흐름으로 앱 배포
argocd app sync app-of-apps

# 4) Grafana / Tempo / Loki 접속 & 대시보드 확인
# 위 관제 스택이 기동되면 트레이스 / 로그 / 지표가 하나의 플랫폼에서 연결됨
