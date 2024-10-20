module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "${local.name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  load_balancer_type = "application"

  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "wordpress-asg"
      }
    }
  }

  target_groups = {
    wordpress-asg = {
      backend_protocol          = "HTTP"
      backend_port              = 80
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path                = "/"
        interval            = 30
        port                = "traffic-port"
        timeout             = 6
        healthy_threshold   = 3 # 2 out of 2 successful checks
        unhealthy_threshold = 3 # 2 out of 2 failed checks
        protocol            = "HTTP"
        matcher             = "200-399"
      }
  } }
}
