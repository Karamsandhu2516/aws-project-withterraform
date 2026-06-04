data "aws_ami" "simple_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}  
resource "aws_lb" "simple_alb" {
  name               = "simple-3tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id]

  tags = {
    Name = "simple-alb"
  }
}

resource "aws_lb_target_group" "simple_tg" {
  name     = "simple-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "simple_http" {
  load_balancer_arn = aws_lb.simple_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simple_tg.arn
  }
}

resource "aws_launch_template" "simple_template" {
  name_prefix   = "simple-template"
  image_id      = data.aws_ami.simple_linux.id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from my clean 3-Tier App!</h1>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "simple_asg" {
  name                = "simple-app-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  
  target_group_arns   = [aws_lb_target_group.simple_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_app[0].id] 

  launch_template {
    id      = aws_launch_template.simple_template.id
    version = "$Latest"
  }
}