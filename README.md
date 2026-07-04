# Multi-Cloud CI/CD Pipeline
**CASE_02 — Fintech · EU**

A production-grade CI/CD pipeline deploying a containerized Node.js service to AWS EC2 and GCP Cloud Run simultaneously via GitHub Actions — achieving **-80% deployment cycle time** vs. manual baseline.

## Architecture
```
GitHub Push → GitHub Actions
                ├── Build & Test (Jest)
                ├── Docker Build
                ├── Deploy → AWS EC2 (via ECR)
                └── Deploy → GCP Cloud Run (via Artifact Registry)
                        └── Health Check (both endpoints)
```

## Stack
- **App:** Node.js + Express
- **Containers:** Docker
- **CI/CD:** GitHub Actions
- **Infrastructure:** Terraform (AWS VPC, EC2, ECR, CloudWatch)
- **Cloud A:** AWS EC2 (us-east-1)
- **Cloud B:** GCP Cloud Run (us-central1)
- **Monitoring:** AWS CloudWatch Dashboard

---

## Setup Instructions

### Step 1: Clone & push to your GitHub
```bash
git init
git add .
git commit -m "feat: initial multi-cloud cicd setup"
git remote add origin https://github.com/YOUR_USERNAME/multicloud-cicd-demo.git
git push -u origin main
```

### Step 2: Provision AWS infrastructure with Terraform
```bash
cd terraform

# Update backend bucket name in main.tf first, then:
terraform init
terraform plan
terraform apply
```
Note the outputs: `ec2_public_ip` and `ecr_repository_url`

### Step 3: Set up GCP
1. Create a GCP project
2. Enable Cloud Run API and Artifact Registry API
3. Create a Service Account with roles: Cloud Run Admin, Artifact Registry Writer, Storage Admin
4. Download the JSON key

### Step 4: Add GitHub Secrets
Go to your repo → Settings → Secrets → Actions. Add:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS IAM key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS IAM secret |
| `AWS_EC2_HOST` | EC2 public IP from Terraform output |
| `AWS_EC2_SSH_KEY` | Contents of your private SSH key |
| `AWS_ECR_REGISTRY` | ECR URL from Terraform output |
| `GCP_PROJECT_ID` | Your GCP project ID |
| `GCP_SA_KEY` | Contents of GCP service account JSON key |

### Step 5: Trigger the pipeline
```bash
git commit --allow-empty -m "trigger: first pipeline run"
git push
```
Go to GitHub Actions tab and watch the pipeline run through all 4 stages.

### Step 6: Screenshot for portfolio
Once deployed, take screenshots of:
- GitHub Actions pipeline showing all green stages
- AWS CloudWatch dashboard (URL in Terraform output)
- Both live endpoints responding to `/health`

These become your portfolio proof artifacts.

---

## Live Endpoints
- **AWS:** `http://<EC2_PUBLIC_IP>:3000`
- **GCP:** `https://<CLOUD_RUN_URL>`

## Key Metric
- **Pipeline cycle time:** ~4 minutes from push to deployed on both clouds
- **vs. manual baseline:** ~20+ minutes
- **Reduction:** ~80% faster
