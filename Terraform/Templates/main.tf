provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "s3-super-puper-website-2021"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "asg_security_group" {
  name        = "magic-asg-security-group"

  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "magic-rds-security-group"

  ingress {
    description      = "Allow 3306 to client host"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "magic-alb" {
  name               = "my-magic-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_security_group.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}

resource "aws_lb_listener" "lblistener" {
  load_balancer_arn = aws_lb.magic-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.magic-tg.arn
  }
}

resource "aws_lb_target_group" "magic-tg" {
  name = "magic-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
}

resource "aws_launch_template" "magic_launch_template" {
  name_prefix   = "my-magic-launch-template"
  image_id      = "ami-0747bdcabd34c712a"
  instance_type = "t2.micro"
  key_name      = "my-magic-key.pem"
  vpc_security_group_ids = [aws_security_group.asg_security_group.id]
}

resource "aws_autoscaling_group" "my-asg" {
  availability_zones = ["us-east-1a", "us-east-1a"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id         = aws_launch_template.magic_launch_template.id
    version    = "$Latest"
  }
}

# scale up alarm
resource "aws_autoscaling_policy" "magic-up-cpu-policy" {
name = "magic-up-cpu-policy"
autoscaling_group_name = "${aws_autoscaling_group.my-asg.name}"
adjustment_type = "ChangeInCapacity"
scaling_adjustment = "1"
cooldown = "300"
policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "magic-up-cpu-alarm" {
alarm_name = "magic-up-cpu-alarm"
alarm_description = "magic-up-cpu-alarm"
comparison_operator = "GreaterThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "70"
dimensions = {
"AutoScalingGroupName" = "${aws_autoscaling_group.my-asg.name}"
}
actions_enabled = true
alarm_actions = ["${aws_autoscaling_policy.magic-up-cpu-policy.arn}"]
}
# scale down alarm
resource "aws_autoscaling_policy" "magic-cpu-policy-scaledown" {
name = "magic-cpu-policy-scaledown"
autoscaling_group_name = "${aws_autoscaling_group.my-asg.name}"
adjustment_type = "ChangeInCapacity"
scaling_adjustment = "-1"
cooldown = "300"
policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "magic-cpu-alarm-scaledown" {
alarm_name = "magic-cpu-alarm-scaledown"
alarm_description = "magic-cpu-alarm-scaledown"
comparison_operator = "LessThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "30"
dimensions = {
"AutoScalingGroupName" = "${aws_autoscaling_group.my-asg.name}"
}
actions_enabled = true
alarm_actions = ["${aws_autoscaling_policy.magic-cpu-policy-scaledown.arn}"]
}