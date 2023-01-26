resource "aws_key_pair" "asg_keypair" {
  key_name   = var.asg_keyname 
  public_key = file("../../../global/keys/${var.asg_keyname}.pub")
}

resource "aws_launch_configuration" "alc" {
  name                        = "${var.asg_name}-lc"  
  image_id                    = var.asg_ami
  instance_type               = var.asg_instance_type
  key_name                    = aws_key_pair.asg_keypair.key_name
  security_groups             = [var.asg_security_group_ids]
  associate_public_ip_address = var.asg_associate_public_ip_address
 // user_data                   = file("../../../global/config/jhttpserver.sh")
  iam_instance_profile        = var.asg_instance_profile

  lifecycle {
    create_before_destroy = true
  }
  /*
  root_block_device {
    delete_on_termination = true
  }
  ephemeral_block_device {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  } 
  */
}

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  launch_configuration      = aws_launch_configuration.alc.name
  vpc_zone_identifier       = var.asg_subnet_ids
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size

  target_group_arns         = var.alb_targetgroup_arn
  health_check_grace_period = "120"
  health_check_type         = "ELB"
  min_elb_capacity          = "1"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = var.asg_name
      propagate_at_launch = true
    },
    {
      key                 = "Tier"
      value               = var.asg_subnet_name
      propagate_at_launch = true
    },
  ]
}

#setup SNS
resource "aws_sns_topic" "alarm" {
  name = var.sns_topicname 
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

# setup cloudwatch alarm - cpu utilization
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name           = "cpu-alarm"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "2"
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = "120"
  statistic            = "Average"
  threshold            = "80"
  alarm_description    = "This metric monitors ec2 cpu utilization"
  alarm_actions        = ["${aws_sns_topic.alarm.arn}"]
  #alarm_actions       = ["${aws_autoscaling_policy.bat.arn}"]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# setup cloudwatch alarm - health status
resource "aws_cloudwatch_metric_alarm" "health" {
  alarm_name            = "web-health-alarm"
  comparison_operator   = "GreaterThanOrEqualToThreshold"
  evaluation_periods    = "1"
  metric_name           = "StatusCheckFailed"
  namespace             = "AWS/EC2"
  period                = "120"
  statistic             = "Average"
  threshold             = "1"
  alarm_description     = "This metric monitors ec2 health status"
  alarm_actions         = ["${aws_sns_topic.alarm.arn}"]

   dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
