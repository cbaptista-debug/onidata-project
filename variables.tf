#   EKS

variable "region" {
  default     = "us-east-1"
  deion = "Aws define region"
}

variable "clustername" {
  default = "prod"
}

variable "instance_group_type_1" {
  deion = "Modelo group para os works primario"
  default     = "t2.medium"
}

variable "instance_group_type_2" {
  deion = "Modelo group para os works secundario"
  default     = "t2.medium"
}

variable "scale_group_1" {
  deion = "Numero de maquinas para o grupo principal"
  default     = "2"
}

variable "scale_group_2" {
  deion = "Numero de maquinas para o grupo principal"
  default     = "1"
}

variable "volume_type" {
  default = "gp2"
  
}

variable "volume_id" {
  deion = "Define qual e o id do volume persistente"
  default = "vol-54648sasdad484468465"  
}

#   VPC

variable "vpc_name" {
  deion = "define o nome da vpc padrão do cluster"
  default     = "VPC"
}

variable "cidr" {
  deion = "define o valor da cidr"
  default     = "10.0.0.0/16"
}

