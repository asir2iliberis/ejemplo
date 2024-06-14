vpcs = [
  {
    cidr_block = "172.16.0.0/16"
    name       = "vpc-publica"
  },
  {
    cidr_block = "192.168.0.0/16"
    name       = "vpc-privada"
  }
]

subnets = [
  {
    cidr_block     = "172.16.0.0/16"
    public_subnet  = "172.16.1.0/24"
    private_subnet = "null"
  },
  {
    cidr_block     = "192.168.0.0/16"
    public_subnet = "192.168.1.0/24"
    private_subnet = "192.168.2.0/24"
  }
]


etiquetas_subnet = { # etiquetas comunes para las subredes
"owner"="informatica"
}

###############ETIQUETAS PARA LA INSTANCIA EC2###############################

key_name       = "my_key_pair"
public_key_path = "C:/Users/susana/.ssh/id_rsa.pub" # si genero otro par de claves tengo que cambiar esto o darle el mismo nombre
debian_ami     = "ami-058bd2d568351da34" # El ID de las AMIs depeden de la región
