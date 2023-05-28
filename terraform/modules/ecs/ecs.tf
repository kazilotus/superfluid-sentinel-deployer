resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "sentinel" {
  name = "/ecs/${var.family_name}"
  tags = var.tags
}

resource "aws_ecs_task_definition" "sentinel" {
  family                   = var.family_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.family_name
      image     = var.image
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.sentinel.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]
    }
  ])

  tags = var.tags
}


resource "aws_ecs_service" "sentinel" {
  name            = var.family_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.sentinel.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  tags = var.tags
}
