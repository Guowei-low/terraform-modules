
# provision network load balancer
resource "aws_lb" "nlb" {
  name                       = var.alb_name
  subnets                    = var.alb_subnetids
  internal                   = var.alb_internal
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  load_balancer_type         = var.load_balancer_type
/*  
  tags = {
    Name                     = var.alb_name
    Tier                     = var.subnet_name
    Terraform                = true
  }  
*/
  tags = merge( {
    Name                     = var.alb_name
    Terraform = "true"
  }, var.customer_tags)    
  //22 Oct 2019, overwrite cross zone load balancing setting to true, default is false
  enable_cross_zone_load_balancing  = true 
}

# provision target group
resource "aws_lb_target_group" "default" {
  count = length(var.albtg_names)
  name                 = element(var.albtg_names, count.index)
  vpc_id               = var.vpc_id  
  port                 = element(var.target_group_ports, count.index)
  protocol             = element(var.target_group_protocols, count.index)
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay  
  slow_start           = var.slow_start 
/*
  tags = {
    Name                = element(var.albtg_names, count.index)
    Tier                = var.subnet_name
    Terraform           = true
  }
*/
  tags = merge( {
    Name                = element(var.albtg_names, count.index)
    Terraform = "true"
  }, var.customer_tags)    

  # force the creation of LB Target Group to be after the creation of Load Balancer.
  depends_on            = [aws_lb.nlb]
}

# create listner
resource "aws_lb_listener" "lb_listener" {
  count = length (aws_lb_target_group.default.*.arn)
  load_balancer_arn = aws_lb.nlb.arn
  port              = element(var.app_lb_listen_ports, count.index) 
  protocol          = element(var.app_lb_listen_protocols, count.index)  

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.default.*.arn, count.index)
  }

   # force the creation of LB Target Group to be after the creation of Load Balancer.
  depends_on            = [aws_lb_target_group.default]
}
