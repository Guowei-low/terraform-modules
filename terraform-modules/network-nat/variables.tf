
# Variable for agency 3 letter code
variable "agency_name" { 
  description = "The 3 letter code for the agency"
}

# Variable for zone : do not change
variable "zone_name" { 
  description = "code for zone - ez,iz,mz,dz"
}

# Variable for environment
variable "env_name" { 
  description = "uat,prd,dev,sit,stg,testing001"
}

variable "subnet_name" {
  description = "name of the subnet"
}

# Variable for availibility zones
variable "az_list" {      
  description = "Define the number of AZ for each subnet block"
  type = list 
}


# Variable for cidr range for subnets
variable "subnets_cidr" {
  description = "List of cidr ranges to be used in the subnets creation"
  type = list
}

# Variable for vpc id
variable "vpc_id" { 
  description = "id for vpc"
}

# Variable for Ids of NAT
variable "nats" {
  description = "List of ID of NAT"
  type = list
  default = []
}

variable "project_code" {
    description = "code for project"
}
