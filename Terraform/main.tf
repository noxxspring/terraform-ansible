provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "todo_sg" {
  name        = "todo_sg"
  description = "Security group for TODO app"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "todo_sg"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.todo_sg.name]
  key_name      = var.key_name

  tags = {
    Name = "TodoAppServer"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[servers]" > ansible/inventory
      echo "app_server ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/appserver.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ansible/inventory
    EOT
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.todo_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  security_group_id = aws_security_group.todo_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  security_group_id = aws_security_group.todo_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.todo_sg.id
}

resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.app_server]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for SSH to be ready..."
      sleep 30
    EOT
  }
}

resource "null_resource" "configure_server" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory ansible/playbook.yml"
  }
}