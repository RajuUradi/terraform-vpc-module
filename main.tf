resource "aws_vpc" "main" {
    cidr_block=var.vpc_cidr
    instance_tenancy="default"
     enable_dns_hostnames = true

    tags=local.vpc_final_tags
}

resource "aws_internet_gateway" "igw"{
    vpc_id=aws_vpc.main.id
    tags=local.igw_final_tags
}

resource "aws_subnet" "public" {
     count = length(var.public_subnet_cidrs)
    vpc_id=aws_vpc.main.id
    cidr_block=var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags=merge(
       local.common_tags,
       var.public_subnet_tags ,
          # roboshop-dev-public-us-east-1a
       {Name="${var.project}-${var.environment}-public-${local.az_names[count.index]}"}
    )
      map_public_ip_on_launch = true 
}

resource "aws_subnet" "private" {
     count = length(var.private_subnet_cidrs)
    vpc_id=aws_vpc.main.id
    cidr_block=var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags=merge(
       local.common_tags,
       var.private_subnet_tags ,
          # roboshop-dev-public-us-east-1a
       {Name="${var.project}-${var.environment}-private-${local.az_names[count.index]}"}
    )
}

resource "aws_subnet" "database" {
     count = length(var.database_subnet_cidrs)
    vpc_id=aws_vpc.main.id
    cidr_block=var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags=merge(
       local.common_tags,
       var.database_subnet_tags ,
          # roboshop-dev-public-us-east-1a
       {Name="${var.project}-${var.environment}-database-${local.az_names[count.index]}"}
    )
}

resource "aws_route_table" "public"{
    vpc_id=aws_vpc.main.id

    tags=merge(var.public_routetable_tags,local.common_tags,{Name="${var.project}-${var.environment}-public"}
    )
}

resource "aws_route_table" "private"{
    vpc_id=aws_vpc.main.id

    tags=merge(var.private_routetable_tags,local.common_tags,{Name="${var.project}-${var.environment}-private"}
    )
}

resource "aws_route_table" "database"{
    vpc_id=aws_vpc.main.id

    tags=merge(var.database_routetable_tags,local.common_tags,{Name="${var.project}-${var.environment}-database"}
    )
}

resource "aws_route_table_association" "public"{
    count=length(var.public_subnet_cidrs)
    route_table_id = aws_route_table.public.id 
    subnet_id= aws_subnet.public[count.index].id 
}

resource "aws_route" "public" {
    route_table_id=aws_route_table.public.id
    destination_cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "private"{
    count=length(var.private_subnet_cidrs)
    route_table_id = aws_route_table.private.id 
    subnet_id= aws_subnet.private[count.index].id 
}

resource "aws_route_table_association" "database"{
    count=length(var.database_subnet_cidrs)
    route_table_id = aws_route_table.database.id 
    subnet_id= aws_subnet.database[count.index].id 
}


resource "aws_eip" "nat"{
   domain ="vpc"
   tags=merge(local.common_tags,var.eip_tags,{Name="${var.project}-${var.environment}-nat"})
}

resource "aws_nat_gateway" "natroboshop"{
    allocation_id = aws_eip.nat.id
    subnet_id=aws_subnet.public[0].id # creating in useast-1a
    tags=merge(local.common_tags,var.nattags,{Name="${var.project}-${var.environment}-nat"})
    depends_on=  [aws_internet_gateway.igw]
}

resource "aws_route" "private" {
    route_table_id=aws_route_table.private.id
    destination_cidr_block="0.0.0.0/0"
    gateway_id = aws_nat_gateway.natroboshop.id
}

resource "aws_route" "database" {
    route_table_id=aws_route_table.database.id
    destination_cidr_block="0.0.0.0/0"
    gateway_id = aws_nat_gateway.natroboshop.id
}
