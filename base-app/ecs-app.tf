resource "aws_lb_target_group" "ghost_fargate" {
  name        = "ghost-fargate"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudx.id
  target_type = "ip"

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
  lifecycle {
    create_before_destroy = true
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "ghost_alb_ecs" {
  name               = "ghost-alb-ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in values(aws_subnet.public) : s.id]

  enable_deletion_protection = false

  tags = {
    Name = "ghost-alb-ecs"
  }
}

resource "aws_lb_target_group" "ghost_fargate_ecs" {
  name        = "ghost-fargate-ecs"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudx.id
  target_type = "ip"

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
  lifecycle {
    create_before_destroy = true
  }
}

# Create ALB Listener
resource "aws_lb_listener" "http_listener_ecs" {
  load_balancer_arn = aws_lb.ghost_alb_ecs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost_fargate_ecs.arn
  }
}




resource "aws_cloudwatch_log_group" "ecr_cluster_ghost" {
  name              = "ecr_cluster_ghost"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "ghost" {
  name = "ghost"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecr_cluster_ghost.name
      }
    }
  }

}

resource "aws_cloudwatch_log_group" "ecs_cluster_ghost_tasks" {
  name              = "/ecs/ghost"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "task_def_ghost" {
  family                   = "task_def_ghost"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ghost_ecs.arn
  execution_role_arn       = aws_iam_role.ghost_ecs.arn
  memory                   = "1024"
  cpu                      = "256"

  volume {
    name = "ghost_volume"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ghost_content.id
    }
  }

  container_definitions = templatefile("container_definitions.json.tpl", {
    ECR_IMAGE = "${aws_ecr_repository.ghost.repository_url}:4.12.1"
    DB_URL    = aws_db_instance.ghost.address
    DB_USER   = aws_db_instance.ghost.username
    PASS      = data.aws_ssm_parameter.my_rds_password.value
    DB_NAME   = aws_db_instance.ghost.db_name
    REGION    = var.region
  })
}


resource "aws_ecs_service" "ghost" {
  name            = "ghost"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.task_def_ghost.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = false
    subnets          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
    security_groups  = [aws_security_group.fargate_pool.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost_fargate.arn
    container_name   = "ghost_container"
    container_port   = 2368
  }
}

resource "aws_ecs_service" "ghost-ecs" {
  name            = "ghost-ecs"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.task_def_ghost.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = false
    subnets          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
    security_groups  = [aws_security_group.fargate_pool.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost_fargate_ecs.arn
    container_name   = "ghost_container"
    container_port   = 2368
  }
}
