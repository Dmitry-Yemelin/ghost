// Generate Password
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"

  keepers = {
    kepeer1 = var.password_keeper_rds
    //keperr2 = var.something
  }
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/ghost/dbpassw"
  description = "The password for the ghost database"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

// Get Password from SSM Parameter Store
data "aws_ssm_parameter" "my_rds_password" {
  name       = "/ghost/dbpassw"
  depends_on = [aws_ssm_parameter.rds_password]
}

resource "aws_db_subnet_group" "ghost" {
  name       = "ghost"
  subnet_ids = [for subnet in values(aws_subnet.private_subnet_db) : subnet.id]

  description = "ghost database subnet group"
}

// Ghost RDS DB with password from SSM Parameter Store
resource "aws_db_instance" "ghost" {
  identifier             = "ghost"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "administrator"
  password               = data.aws_ssm_parameter.my_rds_password.value
  db_subnet_group_name   = aws_db_subnet_group.ghost.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  parameter_group_name   = aws_db_parameter_group.ghost.name
  skip_final_snapshot    = true
  apply_immediately      = true
  db_name                = "ghost"
}

resource "aws_db_parameter_group" "ghost" {
  name   = "ghost"
  family = "mysql8.0"

  parameter {
    name  = "general_log"
    value = "1"
  }
}


output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.ghost.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.ghost.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.ghost.username
}

output "rds_password" {
  description = "RDS instance root password"
  value       = random_string.rds_password.result
}
output "rds_db_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.ghost.db_name

}
