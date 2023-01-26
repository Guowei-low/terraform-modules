# To create AWS directory Service
resource "aws_directory_service_directory" "microsoft-ad" {
  type     = var.type
  name     = var.name
  password = var.password
  edition  = var.edition
  description  = var.description
 
  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}
 
resource "aws_security_group_rule" "sg_rule" {
  count             = length(var.sg_rules)
  type              = element(var.sg_rules[count.index], 0)
  cidr_blocks       = [element(var.sg_rules[count.index], 1)]
  from_port         = element(var.sg_rules[count.index], 2)
  to_port           = element(var.sg_rules[count.index], 3)
  protocol          = element(var.sg_rules[count.index], 4)
  security_group_id = aws_directory_service_directory.microsoft-ad.security_group_id
}