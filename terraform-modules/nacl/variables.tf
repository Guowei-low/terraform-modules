variable "vpc_id" { 
  description = "id for vpc"
}
variable "nacl_name" {
  description = "name of nacl"  
}
variable "nacl_subnetids" {
  description = "List of subnet ids"  
  type = list
}
variable "subnet_name" {
  description = "name of the subnet"
}
variable nacl_rules {
  type = map
  description = "NACL Rules. In the format - egress or ingress | protocol | from_port | to_port | cidr | action"
}
variable "customer_tags" {
   type =map
   default ={}
   description ="addition customer tags"
}