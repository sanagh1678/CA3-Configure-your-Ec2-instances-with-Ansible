# Create a VPC
# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# VPC and subnets
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  count = 2

  cidr_block = "10.0.${count.index}.0/24"
  vpc_id     = aws_vpc.example.id
}

# Route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

# Internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Security group
resource "aws_security_group" "example" {
  name_prefix = "example-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example[0].id

  vpc_security_group_ids = [aws_security_group.example.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF

  tags = {
    Name = "example-instance"
  }
}

# Application Load Balancer
resource "aws_lb" "example" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = [aws_subnet.example[1].id]

  tags = {
    Name = "example-alb"
  }
}

resource "aws_lb_target_group" "example" {
  name_prefix = "example-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.example.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.example.id
  port             = 80
}
