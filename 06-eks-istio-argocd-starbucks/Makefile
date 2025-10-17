init:
\tterraform -chdir=06-eks-istio-argocd-starbucks init
plan:
\tterraform -chdir=06-eks-istio-argocd-starbucks plan
apply:
\tterraform -chdir=06-eks-istio-argocd-starbucks apply -auto-approve
destroy:
\tterraform -chdir=06-eks-istio-argocd-starbucks destroy -auto-approve
port-argocd:
\tkubectl -n argocd port-forward svc/argocd-server 8080:80
