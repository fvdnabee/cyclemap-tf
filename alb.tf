resource "aws_lb" "alb" {
  name               = local.ec2_resources_name
  subnets            = module.vpc.public_subnets
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.default_security_group_id, aws_security_group.allow_tls_plain.id]

  tags = {
    Cluster     = local.name
    Environment = local.environment
  }
}

resource "aws_security_group" "allow_tls_plain" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TCP 80 from world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from world"
    from_port        = 433
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ALLOW ALL egress rule
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Cluster     = local.name
    Environment = local.environment
  }
}

resource "aws_lb_listener" "alb-listener-http" {
  # Redirect HTTP to HTTPS
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-listener-https" {
  # Terminate SSL and forward traffic to ecs service port 8000
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hypercorn-target-group.arn
  }
}

resource "aws_lb_target_group" "hypercorn-target-group" {
  name                 = local.ec2_resources_name
  target_type          = "instance"
  protocol             = "HTTP"
  protocol_version     = "HTTP2" # hypercorn supports HTTP2
  port                 = 8000
  vpc_id               = module.vpc.vpc_id
  # waiting 60 seconds for a deregistered target to transit from draining to
  # unused is sufficient (default is 300)
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
