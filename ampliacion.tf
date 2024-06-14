data "aws_security_group" "grupo_ftp" {
  name = aws_security_group.permitir_ssh.name
}

resource "aws_security_group_rule" "allow_ftp" {
  type              = "ingress"
  from_port         = 20
  to_port           = 21
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.grupo_ftp.id
}

resource "aws_security_group_rule" "allow_high_ports" {
  type              = "ingress"
  from_port         = 1024
  to_port           = 1048
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.grupo_ftp.id
}
