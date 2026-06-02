# 1. Database Subnet Group (Groups our 2 Private Data subnets together)
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.private_data[*].id

  tags = {
    Name = "main-db-subnet-group"
  }
}

# 2. Security Group for Application Load Balancer (Public facing)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP traffic from world"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# 3. Security Group for Application Servers (EC2 instances)
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow traffic ONLY from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Exam Tip: Referencing another SG instead of a CIDR block!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

# 4. Security Group for Database (RDS Instance)
resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Allow MySQL traffic ONLY from the App tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App Servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Chain link security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# 5. RDS MySQL Database Instance
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  max_allocated_storage  = 100 # Enables storage autoscaling to save money/scale up
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro" # Cost-effective instance type
  db_name                = "mydb"
  username               = "admin"
  password               = "SuperSecretPassword123!" # In production we use AWS Secrets Manager, but perfect for portfolio practice
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true # CRITICAL for your practice! Lets you run 'terraform destroy' immediately without hanging or charging you for an extra backup bucket.

  tags = {
    Name = "3-tier-mysql-db"
  }
}