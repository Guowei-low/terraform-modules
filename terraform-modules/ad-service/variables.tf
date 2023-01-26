
  variable "vpc_id" {
      type = string
      description = "vpc id where AD service is attached"
  }

  variable "subnet_ids" {
      type = list
      description ="list of subnet where AD is created"
  }

  variable "description" {
      type =string
      description ="description of microsoft active directory"
  }

  variable "edition"  {
      type = string
      description ="edition of microsoft AD (Standard or Enterprise)"
  }

  variable "password"  {
      type = string
      description ="The password for the directory administrator or connector user"
  }

  variable "name" {
      type =string
      description ="The fully qualified name for the directory, such as corp.example.com"
  }

  variable "type" {
      type =string
      description = "The directory type (SimpleAD, ADConnector or MicrosoftAD are accepted values). Defaults to SimpleAD."
  }

 variable "sg_rules" {
  type = map
  default = {	
    "0" = ["egress", "0.0.0.0/0", "0", "0", "-1"]       
    }
}