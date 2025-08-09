##################################################################################
# DATA
##################################################################################
# AWS System Manager Parameter: secure storage for config data, secret

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  # latest amazon linux 2 ami(amazon machine image)
}

# INSTANCES #
# Create EC2
resource "aws_instance" "nginx" {
  count                  = var.instances_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = module.app.public_subnets[(count.index % var.vpc_public_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = module.web_app_s3.instance_profile.name # attach IAM role to instance
  depends_on             = [module.web_app_s3]                     # ensure IAM role policy is created before instance

  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    s3_bucket_name = module.web_app_s3.web_bucket.id
  })
  # script run at first time instance up
  # define script by herodic syntax with <<EOF EOF

}
