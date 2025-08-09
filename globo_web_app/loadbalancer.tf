# AWS ELB DATA SOURCE
data "aws_elb_service_account" "root" {}
# data source to get the AWS ELB service account ARN 
# so that we can set the S3 bucket policy to allow the ALB to write logs to the S3 bucket


# LOAD BALANCER #
resource "aws_lb" "nginx" {
  name               = "globo-web-alb"
  internal           = false # public facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] # security group for ALB
  subnets            = module.app.public_subnets      # public subnets
  depends_on         = [module.web_app_s3]            # ensure S3 bucket policy is created before ALB

  enable_deletion_protection = false # allow deletion of ALB after terraform destroy

  # enable access logs for the ALB
  access_logs {
    bucket  = module.web_app_s3.web_bucket.id
    enabled = true
    prefix  = "alb-logs" # prefix for the logs in the S3 bucket
  }

  tags = local.common_tags
}

# TARGET GROUP #
resource "aws_lb_target_group" "nginx" {
  name     = "nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.app.vpc_id

  tags = local.common_tags
}

# LOAD BALANCER LISTENER #
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  tags = local.common_tags
}

# TARGET GROUP ATTACHMENT #
resource "aws_lb_target_group_attachment" "nginx" {
  count            = var.instances_count
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx[count.index].id # instance ID of the nginx server
  port             = 80                                 # port on which the nginx server is listening
}
