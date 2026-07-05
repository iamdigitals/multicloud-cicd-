variable "project_name" {
  description = "Short name used to prefix and tag all resources"
  type        = string
  default     = "cicd-demo"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Port the application listens on inside the container"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Path the ALB target group uses for health checks"
  type        = string
  default     = "/health"
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of running tasks under normal load"
  type        = number
  default     = 2
}

variable "app_image_tag" {
  description = "Docker image tag to deploy (overridden per-release by CI)"
  type        = string
  default     = "latest"
}

variable "alarm_email" {
  description = "Email address to notify on CloudWatch alarms (leave blank to skip subscription)"
  type        = string
  default     = ""
}
