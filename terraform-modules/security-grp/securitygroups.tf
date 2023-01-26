# ------------------------------------------------------------------------------
# creates security group and ingress\egress rules
# ------------------------------------------------------------------------------
resource "aws_security_group" "sgrp" {  
  name = var.sg_name    
  description = var.sg_description
  vpc_id=var.vpc_id
/*
  tags = {
   Name      = var.sg_name   
   Tier      = var.subnet_name
   Terraform = "true"
  }
*/
  tags = merge( {
   Name      = var.sg_name   
    Terraform = "true"
  }, var.customer_tags)    
}

resource "aws_security_group_rule" "sg_rule" {
  count             = length(var.sg_rules)
  type              = element(var.sg_rules[count.index], 0)
  cidr_blocks       = [element(var.sg_rules[count.index], 1)]
  from_port         = element(var.sg_rules[count.index], 2)
  to_port           = element(var.sg_rules[count.index], 3)
  protocol          = element(var.sg_rules[count.index], 4)
  description       = element(var.sg_rules[count.index], 5)
  security_group_id = aws_security_group.sgrp.id
}