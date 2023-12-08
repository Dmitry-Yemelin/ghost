data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-*-hvm-*-x86_64-gp2"] #amzn2-ami-kernel-5.10-hvm-2.0.20231101.0-x86_64-gp2
  }
}


# Create an Application Load Balancer (ALB)
resource "aws_lb" "ghost_alb" {
  name               = "ghost-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in values(aws_subnet.public) : s.id]

  enable_deletion_protection = false

  tags = {
    Name = "ghost-alb"
  }
}

# Create a Target Group
resource "aws_lb_target_group" "ghost_ec2" {
  name     = "ghost-ec2"
  port     = 2368
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudx.id

  health_check {
    enabled             = true
    interval            = 7
    path                = "/ghost"
    protocol            = "HTTP"
    timeout             = 2
    healthy_threshold   = 6
    unhealthy_threshold = 2
    matcher             = "200-399"
    port                = 2368
  }
}
# Create ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ghost_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.ghost_ec2.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.ghost_fargate.arn
        weight = 100
      }
    }

  }

}


resource "aws_launch_template" "ghost" {
  name          = "ghost"
  image_id      = "ami-0e8a34246278c21e4" # Replace with the Amazon Linux 2 AMI ID
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_pool.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost_app_profile.name
  }
  key_name               = "ghost-ec2-pool"
  update_default_version = true
  user_data = base64encode(templatefile("user_data.sh.tpl", {
    LB_DNS_NAME     = aws_lb.ghost_alb.dns_name
    DB_URL          = aws_db_instance.ghost.address
    DB_USER         = aws_db_instance.ghost.username
    DB_PASSWORD     = data.aws_ssm_parameter.my_rds_password.value
    DB_NAME         = aws_db_instance.ghost.db_name
    SSM_DB_PASSWORD = aws_ssm_parameter.rds_password.name
  })) #base64encode(file("user_data.sh.tpl"))

  depends_on = [aws_db_instance.ghost]
}

resource "aws_autoscaling_group" "ghost_ec2_pool" {
  name = "ghost_ec2_pool"

  # Assuming you have a VPC with subnets in these AZs
  vpc_zone_identifier = [for subnet in values(aws_subnet.public) : subnet.id]

  # Reference to the launch template
  launch_template {
    id      = aws_launch_template.ghost.id
    version = "$Latest"
  }

  # Desired, Min and Max configuration (adjust as necessary)
  desired_capacity = 2
  min_size         = 2
  max_size         = 3

  # Target Group Attachment
  target_group_arns = [aws_lb_target_group.ghost_ec2.arn]

  # Additional settings like health check, scaling policies, etc.
  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = "0"

  tag {
    key                 = "Name"
    value               = "${aws_launch_template.ghost.name}-${aws_launch_template.ghost.id}"
    propagate_at_launch = true
  }
}








# user_data = templatefile("user_data.sh.tpl", {
#     lb_dns_name = aws_lb.ghost_alb.dns_name
#   })



#   policy = templatefile("${path.root}/files/eks_worker_role_policy.tpl", {
#     dns_zone_id_tpl = data.aws_route53_zone.rtcp.zone_id
#   })
#   "Resource": "arn:aws:route53:::hostedzone/${dns_zone_id_tpl}"

# resource "aws_instance" "my_webserver" {
#   ami                    = "ami-0be2609ba883822ec"
#   instance_type          = "t3.micro"
#   vpc_security_group_ids = [aws_security_group.my_webserver.id]
#   user_data = templatefile("user_data.sh.tpl", {
#     f_name = "Dmitry",
#     l_name = "Yemelin",
#     names  = ["Vasya", "Kolya", "Petya", "John", "Donald", "Masha", "Temp1ar"]
#   })

#   tags = {
#     Name  = "Web Server Build by Terraform"
#     Owner = "Dmitry Yemelin"
#   }
# }
# Owner ${f_name} ${l_name} <br>

# %{ for x in names ~}
# Hello to ${x} from ${f_name}<br>
# %{ endfor ~}

# </html>
