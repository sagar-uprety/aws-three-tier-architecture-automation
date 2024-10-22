data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~>8.0"

  # Autoscaling group
  name = "${local.name}-asg"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.private_subnets
  security_groups           = [module.asg_sg.security_group_id]

  # Traffic source attachment
  traffic_source_attachments = {
    ex-alb = {
      traffic_source_identifier = module.alb.target_groups["wordpress-asg"].arn
      traffic_source_type       = "elbv2" # default
    }
  }

  # Launch template 
  launch_template_name   = "${local.name}-launch-template"
  update_default_version = true

  image_id          = data.aws_ami.amazon-linux.id
  instance_type     = "t2.micro"
  enable_monitoring = true
  user_data         = base64encode(file("${path.module}/${var.provision_script}"))

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for ASG instances"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
  # best practices
  # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "ansible_managed"
  }
}

module "asg_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.name}-http-sg"
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [{
    rule                     = "http-80-tcp"
    source_security_group_id = module.alb.security_group_id
  }]

  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]
}
