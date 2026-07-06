# Terraform — AWS infrastructure

Provisions the AWS side of the pipeline: VPC (public + private subnets across
2 AZs, NAT gateways), ECR repository, ALB, ECS Fargate cluster/service, and
CloudWatch alarms wired to an SNS topic.

## Usage

```bash
terraform init
terraform plan -var="project_name=my-app" -var="alarm_email=you@example.com"
terraform apply
```

The task definition deploys `${ecr_repo}:${app_image_tag}` — CI should build,
push a tagged image, then run `terraform apply -var="app_image_tag=<sha>"`
(or update the task definition directly via `aws ecs update-service` with a
new task def revision — that's what the GitHub Actions workflow will do next).

## Security scan results (tfsec)

This configuration has been through `tfsec` and remediated where it made sense
for a public-facing demo:

**Fixed:**
- ECR, CloudWatch logs, and SNS are encrypted with a customer-managed KMS key (`kms.tf`)
- VPC Flow Logs are enabled and shipped to CloudWatch (`flow-logs.tf`)
- ALB drops invalid headers
- All security group rules have descriptions

**Intentionally accepted (documented inline with `tfsec:ignore` + reasoning):**
- The ALB is public and listens on HTTP only — there's no domain/ACM cert yet.
  See "What's intentionally left out" below for the HTTPS plan.
- Security group egress is open — tasks need outbound access to pull images
  and ship logs; there's no sensitive inbound data to exfiltrate.

## What's intentionally left out

- **Remote state backend** — commented out in `providers.tf`. Point it at an
  S3 bucket + DynamoDB lock table before using this on a real client engagement.
- **HTTPS listener** — only port 80 is open. Add an ACM cert + a 443 listener
  once there's a real domain to attach.
- **Task role permissions** — `aws_iam_role.ecs_task` has no policies attached
  yet. Add least-privilege policies here as the app needs to talk to other
  AWS services (S3, SQS, etc).
- **Autoscaling** — `desired_count` is static. Add an
  `aws_appautoscaling_target`/`policy` pair once there's real traffic data to
  size against.

## Files

| File | Contents |
|---|---|
| `providers.tf` | Terraform/provider config, backend placeholder |
| `variables.tf` | All configurable inputs |
| `vpc.tf` | VPC, public/private subnets, NAT, routing |
| `ecr.tf` | Image repository + lifecycle policy |
| `alb.tf` | Load balancer, target group, listener, security group |
| `ecs.tf` | Cluster, task definition, service, IAM roles |
| `cloudwatch.tf` | Log group, CPU/memory/5xx/unhealthy-host alarms, SNS topic |
| `outputs.tf` | ALB DNS, ECR URL, cluster/service names, log group, SNS ARN |
