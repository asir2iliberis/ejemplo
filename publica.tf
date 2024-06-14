

#Crear la subnet
resource "aws_subnet" "public_subnet" {
  count = length(var.vpcs)
  vpc_id            = aws_vpc.vpc[count.index].id
  cidr_block        = var.subnets[count.index].public_subnet
  availability_zone = var.availability_zones[count.index]
  # Al no poder poner en default_tags + tags que los de las vpcs tengo que hacerlo así para poder usar tags genéricos
  tags = merge(
    var.etiquetas_subnet,
    { Name = "public-subnet-${count.index + 1}" },
    { dev = "desarrollo pública" }

  )
     
  map_public_ip_on_launch = true
  #depends_on = [aws_vpc.vpc[count.index]]
}




# Crear el Internet Gateway
resource "aws_internet_gateway" "gw" {
  count = length(var.vpcs)
  vpc_id = aws_vpc.vpc[count.index].id
  tags = {
    Name = "gw_servicios_externos_${count.index + 1}"
  }
  #depends_on = [aws_vpc.vpc[count.index]]
}

#### Creo una tabla de enrutamiento para el internet gateway####
resource "aws_route_table" "public_subnet_route_table" {
   count = length(var.vpcs)
  vpc_id = aws_vpc.vpc[count.index].id
  
  tags = {
     Name = "public-subnet-route-table-${count.index + 1}"
  }
}

resource "aws_route" "public_subnet_default_route" {
  count = length(var.vpcs)
  route_table_id         = aws_route_table.public_subnet_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw[count.index].id
  # Establecer dependencia explícita del Internet Gateway
  #depends_on = [aws_internet_gateway.gw[count.index]]
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.vpcs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet_route_table[count.index].id
  # Establecer dependencia explícita de la tabla de enrutamiento y la subred
 # depends_on = [aws_route_table.public_subnet_route_table[count.index], aws_subnet.public_subnet[count.index]]
}

