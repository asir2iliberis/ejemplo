

# Crear la subred privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc[1].id
  cidr_block        = var.subnets[1].private_subnet
  availability_zone = var.availability_zones[1]
  # Al no poder poner en default_tags + tags que los de las vpcs tengo que hacerlo así para poder usar tags genéricos
  tags = merge(
    var.etiquetas_subnet,
    { Name = "subred_privada" },
    { dev = "Producción privada" }

  )
     
  map_public_ip_on_launch = false
  # Establecer dependencia explícita del recurso aws_eip.nat_eip
  depends_on = [aws_vpc.vpc[1]]
}



#### Creo un nat-gateway #####
#### Primero una ip elástica####
# Crear una Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
#### y luego el nat asociado a la subred pública existente
# Crear un NAT Gateway en la subred pública
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[1].id

  tags = {
    Name = "nat-gateway"
  }
  # Establecer dependencia explícita del recurso aws_eip.nat_eip
  depends_on = [aws_eip.nat_eip]
  
}



#### Creo una tabla de enrutamiento para la red privada####
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.vpc[1].id
  
  tags = {
    Name = "private-subnet-route-table"
  }
}

resource "aws_route" "private_subnet_default_route" {
  route_table_id         = aws_route_table.private_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
   # Establecer dependencia explícita del NAT Gateway
  depends_on = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
   # Establecer dependencia explícita de la tabla de enrutamiento y la subred
  depends_on = [aws_route_table.private_subnet_route_table, aws_subnet.private_subnet]
}
