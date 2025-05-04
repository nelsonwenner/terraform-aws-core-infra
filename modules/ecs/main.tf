# Cluster ECS
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  tags = merge(var.tags, { Name = "ecs_cluster-${var.env}-${var.project_name}-fargate" })
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg-${var.env}-${var.project_name}-fargate"
  description = "Security group from ALB to ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
    description     = "Allow inbound traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "ecs_sg-${var.env}-${var.project_name}-fargate" })
}

# IAM Role for ECS Task Execution
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs_exec_role-${var.env}-${var.project_name}-fargate"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags = merge(var.tags, { Name = "ecs_exec_role-${var.env}-${var.project_name}-fargate" })
}

# IAM Policy Attachment for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "ecs_task_def-${var.env}-${var.project_name}-fargate"

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = var.image_uri
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          "name" = "ENV_PORT",
          "value" = tostring(var.container_port)
        },
        {
          "name" = "ENVIRONMENT",
          "value" = "${var.env}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_service_log_group.name
          "awslogs-region"        = var.region
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name             = "ecs_service-${var.env}-${var.project_name}-fargate"
  cluster          = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = var.desired_count
  task_definition  = aws_ecs_task_definition.ecs_task_definition.arn

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    container_name   = "web"
    container_port   = var.container_port
    target_group_arn = var.target_group_arn
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 400

  depends_on = [
    aws_cloudwatch_log_group.ecs_service_log_group
  ]

  tags = merge(var.tags, { Name = "ecs_service-${var.env}-${var.project_name}-fargate" })
}

resource "aws_cloudwatch_log_group" "ecs_service_log_group" {
  name              = "ecs_service_log_group-${var.env}-${var.project_name}-fargate"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "ecs_service_log_group-${var.env}-${var.project_name}-fargate" })
}
