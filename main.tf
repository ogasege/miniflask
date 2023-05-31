# Define the provider and region
provider "aws" {
  region = "us-east-1"  
}

# Existing VPC ID
data "aws_vpc" "existing" {
  id = "vpc-025de517f497c3e61"  
}

# Security group for the ECS tasks
resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.existing.id
  name   = "ecs-security-group"

  # Inbound and outbound traffic rules

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS task definition
resource "aws_ecs_task_definition" "task_definition" {
  family                = "miniflask-api-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  

  execution_role_arn    = "arn:aws:iam::888988188010:role/ecr_task_role"  
  
  # Container definition
  container_definitions = jsonencode([
    {
      name      = "miniflask-api-container"
      image     = "public.ecr.aws/g1s5q2a7/miniflask-api:latest"  
      cpu       = 256
      memory    = 512
      port_mappings = [
        {
          container_port = 5000
          host_port      = 5000
          protocol       = "tcp"
        }
      ]
    }
  ])
  
  # Task placement configuration
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }
}

# ECS service
resource "aws_ecs_service" "service" {
  name            = "miniflask-api-service"
  cluster         = "default"  
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Network configuration
  network_configuration {
    subnets          = ["subnet-0822d87ddce4bcbbc", "subnet-094a34598768e9840", "subnet-0d7b7e8378f8e2a0f", "subnet-059978dbf2e899557", "subnet-03699922f580f18bc", "subnet-07c24f3f5bc2c4c2f"]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
