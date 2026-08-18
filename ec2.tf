# ec2.tf

# ---------------------------------------------
# 1. Amazon Linux 2023 最新AMIの自動取得
# ---------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------------------------------------------
# 2. Security Group for EC2 (ALBからのHTTPのみ許可)
# ---------------------------------------------
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow HTTP inbound traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# ---------------------------------------------
# 3. EC2 Instance 1 (Public Subnet 1)
# ---------------------------------------------
resource "aws_instance" "web_1" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true                       # ★追加：パブリックIPの付与
  vpc_security_group_ids      = [aws_security_group.web.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Web Server 1</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server-1"
  }
}

# ---------------------------------------------
# 4. EC2 Instance 2 (Public Subnet 2)
# ---------------------------------------------
resource "aws_instance" "web_2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_2.id
  associate_public_ip_address = true                       # ★追加：パブリックIPの付与
  vpc_security_group_ids      = [aws_security_group.web.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Web Server 2</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server-2"
  }
}

# ---------------------------------------------
# 5. Target Group Attachment (EC2をALBに紐付け)
# ---------------------------------------------
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_2.id
  port             = 80
}