variable "vpcs" {
 description = "Definición de las redes de las dos vpcs"  
  type = list(object({
    cidr_block     = string
    name = string
  }))
}
variable "subnets" {
  type = list(object({
    cidr_block     = string
    public_subnet  = string
    private_subnet = string
  }))
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
#variable "etiquetas_vpc" {
 # type = list(object({
  #  owner     = string
  #  Nombre  = string
  #  dev = string
  #}))
#}
#variable "etiquetas_subnet" {
  #type = list(object({
  #  owner     = string
  #  Nombre  = string
  #  dev = string
 # }))
 variable "etiquetas_vpc"{
  description = "Tag para las dos vpcs creadas"
  type=map(string)
    default = {
   "owner" = "informatica"
   "dev"= "desarrollo"
  }

 }
 variable "etiquetas_subnet"{
  description = "Tag para las subredes de las vpcs creadas"
  type=map(string)
  
 }

 variable "key_name" {
  description = "Nombre del par de claves"
  type        = string
}

variable "public_key_path" {
  description = "Path de la clave pública"
  type        = string
}

variable "debian_ami" {
  description = "AMI ID de debian"
  type        = string
}
