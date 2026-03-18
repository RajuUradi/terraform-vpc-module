

locals {

    common_tags={
        Project=var.project
        Environment=var.environment
        Name= "${var.project}-${var.environment}"
    }

    vpc_final_tags=merge(var.vpctags,local.common_tags)

    igw_final_tags=merge(local.common_tags,var.igwtags)

    az_names = slice(data.aws_availability_zones.available.names,0,2)

}


