# rds.tf

# ---------------------------------------------
# 1. DB Subnet Group (2つのAZのDB Subnetを束ねる)
# ---------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.db_1.id, aws_subnet.db_2.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

# ---------------------------------------------
# 2. Security Group for RDS (EC2からのMySQL通信のみ許可)
# ---------------------------------------------
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL inbound traffic from Web servers only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from Web Security Group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# ---------------------------------------------
# 3. RDS Instance (MySQL Multi-AZ 構成)
# ---------------------------------------------
resource "aws_db_instance" "main" {
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "appdb"
  username               = "admin"
  password               = var.db_password # 検証用パスワード
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = true
  skip_final_snapshot    = true

  tags = {
    Name = "main-rds"
  }
}