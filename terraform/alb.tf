#tfsec:ignore:aws-ec2-no-public-ingress-sgr This is a public demo — the ALB is meant to be reachable on the open internet. See README for the HTTPS/domain roadmap.
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound HTTP from the internet to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tfsec:ignore:aws-ec2-no-public-egress-sgr Outbound-only rule to the internet; the ALB has no inbound-sensitive data to exfiltrate.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

#tfsec:ignore:aws-elb-alb-not-public This ALB is intentionally internet-facing — it's the public entry point for the demo app.
resource "aws_lb" "main" {
  name                        = "${var.project_name}-alb"
  internal                    = false
  load_balancer_type          = "application"
  security_groups             = [aws_security_group.alb.id]
  subnets                     = aws_subnet.public[*].id
  drop_invalid_header_fields  = true

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  # This is the same health gate the deploy pipeline waits on before
  # promoting traffic — keep this path in sync with the app's /health route.
  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  # Short deregistration delay so rolling deploys drain fast without
  # dropping in-flight requests.
  deregistration_delay = 15
}

#tfsec:ignore:aws-elb-http-not-used No ACM certificate or domain is attached yet for this demo — see README for the HTTPS roadmap.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
