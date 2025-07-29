# LOAD BALANCER #
resource "aws_lb" "nginx" {
  name               = "globo-web-alb"
  internal           = false # public facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]                               # security group for ALB
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id] # public subnets

  enable_deletion_protection = false # allow deletion of ALB after terraform destroy

  tags = local.common_tags
}

# TARGET GROUP #
resource "aws_lb_target_group" "nginx" {
  name     = "nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id

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
resource "aws_lb_target_group_attachment" "nginx1" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx1.id # instance ID of the nginx server
  port             = 80                    # port on which the nginx server is listening
}

resource "aws_lb_target_group_attachment" "nginx2" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx2.id # instance ID of the nginx server
  port             = 80                    # port on which the nginx server is listening
}
