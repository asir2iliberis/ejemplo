resource "aws_instance" "debian_instancia" {
  ami             = var.debian_ami
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.debian_key.key_name
  subnet_id       = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.permitir_ssh.id]

  tags = {
    Name = "debian-FTP"
  }

 # user_data = <<-EOF
 #             #!/bin/bash
 #             apt-get update
 #             apt-get upgrade -y
 #             EOF
}




output ftp_ip_publica {

 value = aws_instance.debian_instancia.public_ip
 description= "Ip pública del servidor FTP"
}