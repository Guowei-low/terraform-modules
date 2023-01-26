
# ------------------------------------------------------------------------------
# creates subnets \ route table \ route table association \ route, route attached to interenet gateway
# ------------------------------------------------------------------------------

resource "aws_subnet" "subnets" {  
  count                   = length(var.az_list)
  cidr_block              = element(var.subnets_cidr, count.index)
  vpc_id                  = var.vpc_id
  #map_public_ip_on_launch = "${element(var.public_ip, count.index / length(var.az_list))}"
  availability_zone       = element(var.az_list, count.index)
  tags = {
    Name      = "${format("sub-%[1]s-%[2]s-%[3]s-%[4]s-%[5]s-00%[6]d",substr(element(var.az_list,count.index),length(element(var.az_list, count.index))-1,1),var.project_code,var.env_name,var.zone_name,var.subnet_name,(count.index % length(var.az_list)) + 1)}"
    Tier      = var.subnet_name
    Terraform = "true"
  }
}

resource "aws_route_table" "rtbl" {    
  vpc_id = var.vpc_id
  tags = {
    Name      = "${format("rt-%[1]s-%[2]s-%[3]s-%[4]s-001",var.project_code,var.env_name,var.zone_name,var.subnet_name)}"
    Tier      = var.subnet_name 
    Terraform = "true"
  }
}

resource "aws_route_table_association" "rtbl-association" {
  count          = length(var.az_list)
  subnet_id      = element(aws_subnet.subnets.*.id, count.index) 
  route_table_id = aws_route_table.rtbl.id
 
}
//for public subnet, assocaite internet gateway to route table
resource "aws_route" "itg_route" { 
  route_table_id         = aws_route_table.rtbl.id
  destination_cidr_block = "0.0.0.0/0"  
  gateway_id             =  var.igw_id      
}

