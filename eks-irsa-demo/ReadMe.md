# Architecture Overview (EKS IRSA)

        ┌─────────────────────────────┐
        │        AWS IAM Roles        │
        └─────────────┬───────────────┘
                      │ IRSA Trust
                      ▼
           ┌──────────────────────┐
           │   EKS OIDC Provider  │
           └─────────────┬────────┘
                         │
                         ▼
           ┌──────────────────────────────┐
           │ ServiceAccounts per Service   │
           │  (cart, order, payment, etc.) │
           └──────────────────────────────┘

#### Each service (cart/order/payment) gets its own IAM role with minimum permissions using IRSA.
This pattern mimics how modern e-commerce systems isolate workloads for compliance and security.


## 🛡 Example Services


## Technologies
	•	AWS EKS
	•	Terraform >= 1.6
	•	IAM Roles for Service Accounts (IRSA)
	•	Dynamic JSON policies via templatefile()
	•	Local backend (demo) / S3 remote ready
	•	Fully modular and environment-aware


  ## Folder Structure
eks-irsa-demo/
├─ main.tf
├─ versions.tf
├─ variables.tf
├─ outputs.tf
├─ templates/
│  ├─ policy-cart.json.tpl
│  ├─ policy-order.json.tpl
│  └─ policy-payment.json.tpl
└─ modules/
└─ irsa/
├─ main.tf
├─ variables.tf
└─ outputs.tf



