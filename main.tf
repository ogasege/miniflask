# Provider definition and region
provider "aws" {
  region = "us-east-1"  
}

# Existing VPC definition
data "aws_vpc" "existing" {
  id = "vpc-025de517f497c3e61"  
}

# Security group for the ECS tasks
resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.existing.id
  name   = "ecs-security-group"
  # Define the desired ingress and egress rules for your tasks
  # For example, allow inbound traffic on port 5000
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
  
  # Defining the task placement configuration
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }
}

# Creating an ECS service
resource "aws_ecs_service" "service" {
  name            = "miniflask-api-service"
  cluster         = "default"  
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Defining the network configuration
  network_configuration {
    subnets          = data.aws_vpc.existing.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# Retrieve the ECS cluster details
data "aws_ecs_cluster" "cluster" {
  cluster_name = "default"  
}

# Output the public IP address of the ECS service
output "public_ip_address" {
  value = aws_ecs_service.service.load_balancer.first.public_ip
}
