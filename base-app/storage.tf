resource "aws_efs_file_system" "ghost_content" {
  creation_token = "ghost_content"

  tags = {
    Name = "ghost_content"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  for_each        = aws_subnet.public
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs.id]
}
