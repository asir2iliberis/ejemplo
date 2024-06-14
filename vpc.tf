
#########LA IDEA ES DEJARLO TODO CON UN SOLO RECURSO ################################33


resource "aws_vpc" "vpc" {
  count = length(var.vpcs)
  cidr_block = var.vpcs[count.index].cidr_block
    tags = merge(
    var.etiquetas_vpc,
    { Name = var.vpcs[count.index].name }
  )
}

#############CREAR GRUPO DE SEGURIDAD ###################################
# Si hace falta porque aunque se crea uno por defecto permite todo el tráfico
# y yo tengo que restringirlo al puerto 22 y asignar este grupo a la instancia.

   resource "aws_security_group" "permitir_ssh" {
     vpc_id = aws_vpc.vpc[0].id

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

     tags = {
       Name = "allow_ssh"
     }
   }

##################SE SUPONE QUE ESTO ES LA AMPLIACIÓN A DOS REGLAS MÁS PERO ME GENERA DUDAS:#
#1. NO SE PUEDE PONER EN UN ARCHIVO APARTE###################
#2. PUEDE HACERSE SOBRE UN GRUPO YA CREADO A LO MEJOR ES MÁS INTERESANTE CUANDO IMPORTO UN GRUPO QUE
#FUE CREADO CON UNA GRÁFICA Y LO AÑADO
# data "aws_security_group" "grupo_ftp" {
#   name = aws_security_group.permitir_ssh.name
# }

# resource "aws_security_group_rule" "allow_ftp" {
#   type              = "ingress"
#   from_port         = 20
#   to_port           = 21
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = data.aws_security_group.grupo_ftp.id
# }

# resource "aws_security_group_rule" "allow_high_ports" {
#   type              = "ingress"
#   from_port         = 1024
#   to_port           = 1048
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = data.aws_security_group.grupo_ftp.id
# }

################PEERING CONECTIONS ####################
# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc[0].id
  peer_vpc_id   = aws_vpc.vpc[1].id
  #peer_region   = "us-east-1" # Adjust if your VPCs are in different regions
  auto_accept   = true
  tags = {
    Name = "vpc-peering-connection"
  }
}

#######################################################################

# En realidad la tabla de enturamiento se crea automaticamente y la VPC
# no se necesita salida a intenet eso sería en la subred pública
# luego este bloque no sería necesario, aun así lo mantengo como documentación
# recupera el id de la vpc, de el recupera el ide de la tabla, filtrando por la principal
# posteriormente agrega la ruta.
# Recuperar la ID de la tabla de enrutamiento predeterminada de la VPC
data "aws_vpc" "selected_vpc" {
  count = length(var.vpcs)
  id = aws_vpc.vpc[count.index].id
}
# Obtener la tabla de enrutamiento predeterminada asociada a la VPC
data "aws_route_table" "tabla_enrutamiento_principal" {
  count = length(var.vpcs)
  vpc_id = data.aws_vpc.selected_vpc[count.index].id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# Agregar una nueva ruta a la tabla de enrutamiento predeterminada
resource "aws_route" "tabla_enrutamiento_principal" {
  route_table_id         = data.aws_route_table.tabla_enrutamiento_principal[0].id
  destination_cidr_block = var.vpcs[1].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id   
   
}
# Agregar una nueva ruta a la tabla de enrutamiento predeterminada
resource "aws_route" "default_route" {
  route_table_id         = data.aws_route_table.tabla_enrutamiento_principal[1].id
  destination_cidr_block = var.vpcs[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id   
   
}
#################################################################################################





