#----------------------------------------------------------------------------
# creates application load balancer\Target group\S3 bucket.
# ----------------------------------------------------------------------------
# setup s3 bucket policy for storing alb logs
/*
resource "aws_s3_bucket_policy" "s3policy_alb" {
  bucket = var.s3_logbucketid

  policy = <<POLICY
{
  "Id": "Policy1429136655940-20190711",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1429136633762-20190711",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${var.s3_logbucketarn}/alblogs-${var.subnet_name}/*",
      
      "Principal": {
        "AWS": [
          "850871764653"
        ]
      }
    }
  ]
}
  POLICY
 
}

*/
#########################
# S3 bucket for ELB logs
#########################
data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket" "logs" {
  bucket        = var.s3_bucketname
  acl           = "private"
  policy        =  length(var.s3_access_principles) > 0 ?  data.aws_iam_policy_document.logsmore[0].json : data.aws_iam_policy_document.logs[0].json
  force_destroy = true
  versioning { enabled = true }

  tags = {
    Name          = var.s3_bucketname
    tier          = var.subnet_name 
  }

// //life cycle policy for load balancer bucket files, 13/11/2019
 lifecycle_rule {
    prefix  = "/"
    enabled = true

     //life cycle policy for load balancer bucket files, 13/11/2019

    abort_incomplete_multipart_upload_days = 14

    transition {
      days          = var.transition_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      expired_object_delete_marker = var.expiration_expired_object_delete_marker
      days          = var.expiration_days
    }
 
    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_glacier_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {    
      days = var.noncurrent_version_expiration_days
    } 
  }  //end of lifecycle_rule
 
  //encryption option, 15/11/2019
   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.app_lb_bucket_kms_master_key_id
        sse_algorithm     = var.app_lb_bucket_sse_algorithm
      }
    }
  }
 
}
//20/9/2019, make bucket itself private, no public access at all, start
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = "${aws_s3_bucket.logs.id}"
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets  = true 
  ignore_public_acls  = true 
}


//20/9/2019, make bucket itself private, no public access at all, end
data "aws_iam_policy_document" "logs" {
  count = length(var.s3_access_principles) > 0 ? 0: 1
  statement {
    actions = [
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucketname}/alblogs-${var.subnet_name}/*",
    ]
  }
  
    
}

//20/9/2019, make bucket itself private, no public access at all, end
data "aws_iam_policy_document" "logsmore" {
  count = length(var.s3_access_principles) > 0 ? 1: 0
  statement {
    actions = [
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucketname}/alblogs-${var.subnet_name}/*",
    ]
  }
  
  // 13/11/2019 S3 objects
    statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = var.s3_access_principles
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucketname}/alblogs-${var.subnet_name}/*",
    ]
  }

    // 13/11/2019, list bucket 
    statement {
    actions = [
      "s3:ListBucket",
    ]

    principals {
      type        = "AWS"
      identifiers = var.s3_access_principles
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucketname}",
    ]
  }
  
}


# provision alb
resource "aws_lb" "alb" {
  name                       = var.alb_name
  security_groups            = var.enable_multiple_security_group_association ? var.alb_sgids_msg : [var.alb_sgids]
  subnets                    = var.alb_subnetids
  internal                   = var.alb_internal
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  load_balancer_type         = "application"
  
  access_logs {
    bucket                   = var.s3_bucketname
    prefix                   = "alblogs-${var.subnet_name}"
    #interval                = "${var.access_logs_interval}"
    enabled                  = true
  }
  
  tags = {
    Name                     = var.alb_name
    Tier                     = var.subnet_name
    Terraform                = true
  }  
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
  
  health_check {    
    path                = var.health_check_path    
    healthy_threshold   = var.health_check_healthy_threshold  
    unhealthy_threshold = var.health_check_unhealthy_threshold  
    timeout             = var.health_check_timeout   
    interval            = var.health_check_interval   
    matcher             = var.health_check_matcher  
    port                = element(var.target_group_ports, count.index) 
    protocol            = element(var.target_group_protocols, count.index)
  }

  stickiness {
      type = var.stickiness_type
      cookie_duration =var.stickiness_cookie_duration
      enabled  = var.stickiness_enabled
  }
 
  tags = {
    Name                = element(var.albtg_names, count.index)
    Tier                = var.subnet_name
    Terraform           = true
  }

  # force the creation of LB Target Group to be after the creation of Load Balancer.
  depends_on            = [aws_lb.alb]
}

# create listner
resource "aws_lb_listener" "lb_listener" {
 // count = length (aws_lb_target_group.default.*.arn)
  count = length (var.app_lb_listen_ports)
  load_balancer_arn = aws_lb.alb.arn
  port              = element(var.app_lb_listen_ports, count.index) 
  protocol          = element(var.app_lb_listen_protocols, count.index)

   default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.default.*.arn, count.index)
  }
  ssl_policy        =  element(var.app_lb_listen_protocols, count.index) == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   =  element(var.app_lb_listen_protocols, count.index) == "HTTPS" ? var.certificate_arn : null
   # force the creation of LB Target Group to be after the creation of Load Balancer.
  depends_on            = [aws_lb_target_group.default]
}


resource "aws_lb_listener_rule" "path_base_rule" {
  count   = var.app_lb_path_pattern_flag == "true" ? length(var.app_lb_fordward_path_condition_list) : 0
  listener_arn =element(aws_lb_listener.lb_listener.*.arn, length(aws_lb_listener.lb_listener.*.arn)>1?  count.index : 0)
  priority     = 100+ count.index*10

  action {
    type             = "forward"
    target_group_arn =  element(aws_lb_target_group.default.*.arn, count.index+1)
  }

  condition {
    //field  ="path-pattern"    
    path_pattern {
      values = [element(var.app_lb_fordward_path_condition_list,count.index)]
    }     
  }
}