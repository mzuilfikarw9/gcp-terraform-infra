🎫 Scalable Cloud-Native Ticket Platform
A high-performance, microservices-based ticketing application deployed on Google Kubernetes Engine (GKE). This project demonstrates a production-grade GitOps workflow, auto-scaling infrastructure, and managed database persistence on GCP.

🏗️ Architecture
Compute: Google Kubernetes Engine (GKE) with Cluster Autoscaling.

Frontend: React.js (Nginx container).

Backend: Go (Golang) REST API.

Database: Google Cloud SQL (PostgreSQL 15) via Private IP.

Messaging: Kafka (deployed in-cluster).

Ingress: GCE L7 Load Balancer.

CI/CD: ArgoCD (GitOps).

Observability: Google Cloud Logging (Stackdriver) & Horizontal Pod Autoscaling.

📂 Repository Structure
Plaintext
GCP-TERRAFORM-INFRA/
├── backend/            # Go source code (API)
├── frontend/           # React source code (UI)
├── ticket-chart/       # Helm Charts for Frontend, Backend, Kafka
├── environments/       # Terraform configurations for specific envs (e.g., sit, prod)
├── modules/            # Reusable Terraform modules (VPC, GKE, SQL)
├── k8s/                # Raw Kubernetes manifests (if any)
├── .gitignore
└── README.md           # Project documentation
🚀 Prerequisites
Ensure you have the following installed:

gcloud CLI

kubectl

terraform

docker (with Buildx support)

argocd CLI (optional)

🛠️ Deployment Guide
Phase 1: Infrastructure Provisioning (Terraform)
Provision the VPC, GKE Cluster, and Cloud SQL instance.

Bash
# Navigate to your environment folder (e.g., sit)
cd environments/sit

# Initialize and Apply
terraform init
terraform apply
# Type 'yes' to confirm
Note: Terraform will output the Database Password. Save this for later.

Phase 2: Build & Push Artifacts
Build Docker images targeting Linux/AMD64 (critical for GKE if building on Apple Silicon).

Bash
# 1. Enable Docker Buildx
docker buildx create --use

# 2. Build Backend
cd ../../backend
docker buildx build --platform linux/amd64 -t gcr.io/YOUR_PROJECT/ticket-backend:v1 . --push

# 3. Build Frontend
cd ../frontend
docker buildx build --platform linux/amd64 -t gcr.io/YOUR_PROJECT/ticket-frontend:v1 . --push
Phase 3: Deploy with ArgoCD (GitOps)
Bootstrap ArgoCD and sync the Helm chart located in ticket-chart.

Bash
# 1. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Apply Application Manifest
# Ensure your ArgoCD App points to the 'ticket-chart' path in this repo
kubectl apply -f k8s/argocd-app.yaml
📈 Auto-Scaling & Stress Testing
This system uses Horizontal Pod Autoscaling (HPA) based on CPU utilization.

Configuration (ticket-chart/values.yaml)
Trigger: Scale up when CPU > 70%.

Min Replicas: 2

Max Replicas: 10

How to Run a Stress Test
To verify autoscaling, simulate a massive load spike:

Watch the HPA status:

Bash
kubectl get hpa -w
Generate Artificial Load: Exec into a backend pod and run an infinite loop:

Bash
kubectl exec -it <BACKEND_POD_NAME> -- sh
# Inside the pod:
while true; do :; done
Result: You will see replicas increase: 2 -> 4 -> 8 -> 10.

🔧 Troubleshooting / Runbook
Issue 1: "Exec Format Error" (CrashLoopBackOff)
Symptom: Pods crash immediately after starting.

Cause: Image built on Apple M1 (ARM64) but running on GKE (AMD64).

Fix: Rebuild using --platform linux/amd64.

Issue 2: 502 Bad Gateway
Symptom: Load Balancer returns 502.

Cause: Traffic sent to pod before app is listening.

Fix: Ensure readinessProbe is configured in ticket-chart/templates/deployment.yaml.

Issue 3: HPA Shows <unknown>/70%
Symptom: Autoscaler refuses to calculate metrics.

Cause: Missing resource requests in deployment.

Fix: Add resources.requests.cpu: "100m" to ticket-chart/values.yaml.

Issue 4: Database Connection Failures
Symptom: Backend cannot connect to Cloud SQL.

Checklist:

Is the DB password correct in the Kubernetes Secret?

Is the VPC Peering (Private Service Access) enabled?

Debug Tip: Temporarily patch instance to Public IP to verify connectivity:

Bash
gcloud sql instances patch sit-postgres-instance --assign-ip
🧹 Cleanup (Kill Switch)
⚠️ IMPORTANT: Run these commands to stop billing immediately.

Bash
# 1. Destroy GKE Cluster
gcloud container clusters delete ticket-cluster --zone asia-southeast1-a --quiet

# 2. Destroy Cloud SQL Instance (Must be done separately!)
gcloud sql instances delete sit-postgres-instance --quiet

# 3. Delete Artifact Registry Images
gcloud artifacts repositories delete ticket-repo --location asia-southeast1 --quiet



## 1. Login if you haven't already
gcloud auth login

## 2. Set your current project
gcloud config set project my-company-sit-platform

##Terraform uses your "Application Default Credentials" (ADC) to authenticate. Currently, your local credential file is stamped with an old project ID. If you run Terraform now, it might try to bill/quota the wrong project.##
Run this command to fix it:
gcloud auth application-default set-quota-project my-company-sit-platform

If looks like the authentication process was interrupted or the permissions were not fully granted on the consent screen
Force Clean Login (No Browser)
## gcloud auth application-default login --no-browser --scopes=https://www.googleapis.com/auth/cloud-platform #
It will print a long URL starting with https://accounts.google.com/...

## Copy that full URL and paste it into your web browser.
Log in with your account.
CRITICAL: When asked for permission, you MUST check the box that says:

"See, edit, configure, and delete your Google Cloud Platform data"

It will give you a code. Copy the code and paste it back into your terminal prompt.

Step 2: Set the Quota Project Again
Once the login succeeds (it will say Credentials saved to file...), run the command that failed earlier:

## gcloud auth application-default set-quota-project my-company-sit-platform ##

Step 3: Resume Infrastructure Build
Now you can create the bucket and run Terraform:
## 1. Create Bucket
gcloud storage buckets create gs://tf-state-my-company-sit \
    --project=my-company-sit-platform \
    --location=asia-southeast1 \
    --uniform-bucket-level-access

## 2. Run Terraform
terraform init


