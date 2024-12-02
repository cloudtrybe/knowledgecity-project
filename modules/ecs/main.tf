resource "aws_ecs_cluster" "main" {
  name = "${terraform.workspace}-cluster"
  tags = {
    Name      = "${terraform.workspace}-ecs-cluster"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRol1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_tasks" {
  for_each    = var.services
  name        = "${terraform.workspace}-${each.key}-task-sg"
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = each.value.port
    to_port         = each.value.port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "main" {
  for_each                 = var.services
  family                   = "${terraform.workspace}-${each.key}-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn            = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = each.value.image
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
        }
      ]
      environment = each.value.environment
    }
  ])
}

resource "aws_ecs_service" "main" {
  for_each        = var.services
  name            = "${terraform.workspace}-${each.key}-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks[each.key].id]
    assign_public_ip = each.value.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main[each.key].arn
    container_name   = each.key
    container_port   = each.value.port
  }

  tags = {
    Name      = "${terraform.workspace}-${each.key}-svc"
    Automated = "yes"
    CreatedBy = "Terraform"
  }

  depends_on = [
    aws_security_group.ecs_tasks,
    aws_ecs_task_definition.main,
    aws_lb_target_group.main
  ]
}

resource "aws_lb_target_group" "main" {
  for_each    = var.services
  name        = "${terraform.workspace}-${each.key}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = each.value.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
    interval            = 30
  }
}

resource "aws_lb_listener_rule" "static" {
  for_each     = var.services
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  # Uncomment and modify the host_header condition if needed
  # condition {
  #   host_header {
  #     values = [".com"]
  #   }
  # }
}

resource "aws_appautoscaling_target" "ecs" {
  for_each           = var.enable_service_autoscaling ? var.services : {}
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out" {
  for_each           = var.enable_service_autoscaling ? var.services : {}
  name               = "${terraform.workspace}-${each.key}-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = each.value.scale_out_target_value
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}

resource "aws_appautoscaling_policy" "scale_in" {
  for_each           = var.enable_service_autoscaling ? var.services : {}
  name               = "${terraform.workspace}-${each.key}-scale-in"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = each.value.scale_in_target_value
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}