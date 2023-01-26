
variable "vpc_id" { 
  description = "id for vpc"
}
variable "sg_name" {  
  description = "security group name"  
}
variable "subnet_name" {  
  description = "subnet name"  
}
variable "sg_description" {
  default = "description for Security Group"
}
variable "sg_rules" {
  description = "security group rules"  
  type = map
}
variable "customer_tags" {
   type =map
   default ={}
   description ="addition customer tags"
}