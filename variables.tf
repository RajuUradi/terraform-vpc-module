variable "vpc_cidr"{
    default="10.0.0.0/16"
}

variable "project"{
    type=string
}

variable "environment"{
    type=string
}

variable "vpctags"{
    type=map
    default={}
}

variable "igwtags"{
    type=map
    default={}
}

variable "public_subnet_cidrs" {
    type=list
  default=["10.0.1.0/24", "10.0.2.0/24" ]
}

variable "public_subnet_tags"{
    type=map
    default={}
}

variable "public_routetable_tags"{
    type=map
    default={}
}


variable "private_routetable_tags"{
    type=map
    default={}
}


variable "database_routetable_tags"{
    type=map
    default={}
}


variable "private_subnet_cidrs" {
    type=list
  default=["10.0.10.0/24", "10.0.11.0/24" ]
}

variable "private_subnet_tags"{
    type=map
    default={}
}

variable "database_subnet_cidrs" {
    type=list
  default=["10.0.20.0/24", "10.0.21.0/24" ]
}

variable "database_subnet_tags"{
    type=map
    default={}
}

variable "eip_tags"{
    type=map
    default={}
}

variable "nattags"{
    type=map
    default={}
}