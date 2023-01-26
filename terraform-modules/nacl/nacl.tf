# ------------------------------------------------------------------------------
# create nacl and inbound\outbound rules
# ------------------------------------------------------------------------------
resource "aws_network_acl" "nacl" { 
  vpc_id= var.vpc_id
  subnet_ids = var.nacl_subnetids
/*  tags = {
    Name      = var.nacl_name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
*/
  tags = merge( {
    Name      = var.nacl_name
    Terraform = "true"
  }, var.customer_tags)    
}

resource "aws_network_acl_rule" "nacl_rule" {
  count             = length(var.nacl_rules)
 // rule_number       = (count.index + 1)*10
  network_acl_id    = aws_network_acl.nacl.id
  egress            = element(var.nacl_rules[count.index], 0)  
  protocol          = element(var.nacl_rules[count.index], 1)
  from_port         = element(var.nacl_rules[count.index], 2)
  to_port           = element(var.nacl_rules[count.index], 3)
  cidr_block        = element(var.nacl_rules[count.index], 4)
  rule_action       = element(var.nacl_rules[count.index], 5) 
  rule_number       = element(var.nacl_rules[count.index], 6) 
}

