
variable "alb_subnetids" {  
  description = "subnet ids"  
}
variable "alb_sgids" {  
  description = "security group ids"  
}
variable "subnet_name" {  
  description = "subnet name"  
}
variable "alb_name" {  
  description = "name of the application load balancer"  
}
variable "alb_internal" {  
  description = "internal or external alb"  
}
variable "s3_bucketname" {
  description = "id of the bucket."
}

variable "s3_bucketregion"{
  description = "region for the bucket" 
}
variable "enable_http_listener" {
  default     = true
  type        = string
  description = "If true, the HTTP listener will be created."
}
variable "https_port" {
  default     = 443
  type        = string
  description = "The HTTPS port."
}

variable "http_port" {
  default     = 80
  type        = string
  description = "The HTTP port."
}

variable "fixed_response_content_type" {
  default     = "text/plain"
  type        = string
  description = "The content type. Valid values are text/plain, text/css, text/html, application/javascript and application/json."
}

variable "fixed_response_message_body" {
  default     = "404 Not Found"
  type        = string
  description = "The message body."
}

variable "fixed_response_status_code" {
  default     = "404"
  type        = string
  description = "The HTTP response code. Valid values are 2XX, 4XX, or 5XX."
}
variable "target_group_ports" {
  default     = ["22"]
  type        = list
  description = "The ports on which targets receive traffic, unless overridden when registering a specific target."
}

variable "target_group_protocols" {
  default     = ["TCP"]
  type        = list
  description = "The protocol to use for routing traffic to the targets. Should be one of HTTP or HTTPS."
}

variable "target_type" {
  default     = "instance"
  type        = string
  description = "The type of target that you must specify when registering targets with this target group. The possible values are instance or ip."
}

variable "deregistration_delay" {
  default     = "300"
  type        = string
  description = "The amount time for the load balancer to wait before changing the state of a deregistering target from draining to unused."
}

variable "slow_start" {
  default     = "0"
  type        = string
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests."
}

variable "health_check_path" {
  default     = "/"
  type        = string
  description = "The destination for the health check request."
}

variable "health_check_healthy_threshold" {
  default     = "2"
  type        = string
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
}

variable "health_check_unhealthy_threshold" {
  default     = "10"
  type        = string
  description = "The number of consecutive health check failures required before considering the target unhealthy."
}

variable "health_check_timeout" {
  default     = "120"
  type        = string
  description = "The amount of time, in seconds, during which no response means a failed health check."
}

variable "health_check_interval" {
  default     = "30"
  type        = string
  description = "The approximate amount of time, in seconds, between health checks of an individual target."
}

variable "health_check_matcher" {
  default     = "200-499"
  type        = string
  description = "The HTTP codes to use when checking for a successful response from a target."
}

variable "health_check_port" {
  default     = "traffic-port"
  type        = string
  description = "The port to use to connect with the target."
}

variable "health_check_protocol" {
  default     = "HTTP"
  type        = string
  description = "The protocol to use to connect with the target."
}
variable "albtg_names" {
  type        = list
  description = "a list name of the alb target groups."
}

variable "vpc_id" { 
  description = "id for vpc"
}

variable "listener_rule_priority" {
  default     = 50000
  type        = string
  description = "The priority for the rule between 1 and 50000."
}

variable "listener_rule_condition_field" {
  default     = "path-pattern"
  type        = string
  description = "The name of the field. Must be one of path-pattern for path based routing or host-header for host based routing."
}

variable "listener_rule_condition_values" {
  default     = ["/*"]
  type        = list
  description = "The path patterns to match. A maximum of 1 can be defined."
}

variable "app_lb_listen_ports" {
  default     = ["22"]
  type        = list
  description = "For a list of port to be listened by application load balancer."
}

variable "app_lb_listen_protocols" {
  default     = ["TCP"]
  type        = list
  description = "For a list of protocal to be listened by application load balancer."
}


variable "load_balancer_type" {
  default     ="network"
  description ="load balancer type : netork or application"
}

variable "alb_idle_timeout" {
   default ="60"
   description = "idle time out in seconds"
}


variable "enable_deletion_protection" {
  default = false
  description = " (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer, default is false"
  
}

variable "customer_tags" {
   type =map
   default ={}
   description ="addition customer tags"
}