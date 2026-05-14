provider "aws" {
  region = "ap-south-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Web Security Group
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "default-db-subnet"
  subnet_ids = data.aws_subnets.default.ids
}

# RDS Instance
resource "aws_db_instance" "mysql_db" {
  identifier        = "simple-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "webappdb"
  username = "admin"
  password = "admin12345"

  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name

  publicly_accessible = true
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0f559c3642608c138"
  instance_type = "t3.micro"

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd

systemctl start httpd
systemctl enable httpd

cat <<EOT > /var/www/html/index.php
<!DOCTYPE html>
<html>
<head>
    <title>Simple Form</title>
</head>
<body>
    <h2>User Form</h2>

    <form method="post">
        Name: <input type="text" name="name" required><br><br>
        Email: <input type="email" name="email" required><br><br>
        <input type="submit" name="submit" value="Submit">
    </form>

<?php
\$conn = new mysqli("${aws_db_instance.mysql_db.address}", "admin", "admin12345", "webappdb");

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

\$conn->query("CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50)
)");

if (isset(\$_POST['submit'])) {
    \$name = \$_POST['name'];
    \$email = \$_POST['email'];

    \$sql = "INSERT INTO users (name, email) VALUES ('\$name', '\$email')";
    
    if (\$conn->query(\$sql) === TRUE) {
        echo "<p>Data inserted successfully!</p>";
    } else {
        echo "Error: " . \$conn->error;
    }
}
?>
</body>
</html>
EOT

EOF

  tags = {
    Name = "SimpleWebServer"
  }
}

# Output URL
output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}