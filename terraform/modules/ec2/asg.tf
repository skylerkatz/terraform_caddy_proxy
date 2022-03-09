resource "aws_autoscaling_group" "this" {
  launch_template {
    name    = aws_launch_template.launch_template.name
    version = "$Latest"
  }

  name                 = "caddy-${var.infra_role}-asg-${var.infra_env}"
  vpc_zone_identifier  = var.asg_subnets
  max_size             = var.asg_max_instances
  min_size             = var.asg_min_instances
  desired_capacity     = var.asg_desired_instances
  termination_policies = ["OldestInstance"]

  health_check_type         = "ELB"
  health_check_grace_period = 90 # Seconds

  lifecycle {
    # see notes in https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
    ignore_changes = [load_balancers, target_group_arns]
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
    }
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_http" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = aws_lb_target_group.http.arn
}

resource "aws_autoscaling_attachment" "asg_attachment_https" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = aws_lb_target_group.https.arn
}
