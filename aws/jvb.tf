resource "aws_launch_template" "jvb" {
  image_id = var.ami_id
  count    = 3
  name     = "jvb-launch-template-${count.index}"
  user_data = base64encode(templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
    setup_type                = "jvb"
    region                    = var.aws_region
    hostname                  = "${var.aws_region}-jicofo${count.index}.${var.subdomain}.${var.parent_subdomain}"
    jvb_secret                = local.jvb_secret
    xmpp_server               = local.xmpp_server
    xmpp_password             = local.xmpp_password
    email_address             = var.email_address
    admin_username            = var.admin_username
    admin_password            = var.admin_password
    jibri_installation_script = var.enable_recording_streaming ? templatefile("${path.module}/install_jibri.tpl", {}) : "echo \"Jibri installation is disabled\" >> /debug.txt"
    reboot_script             = var.enable_recording_streaming ? "echo \"Rebooting...\" >> /debug.txt\nreboot" : "echo \".\" >> /debug.txt"
  }))

  instance_type = "t3.medium"

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
}

resource "aws_autoscaling_group" "jvb" {
  count               = 3
  desired_capacity    = 3
  min_size            = 3
  max_size            = 6
  vpc_zone_identifier = [aws_default_subnet.default.id]

  launch_template {
    id      = aws_launch_template.jvb[count.index].id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "jitsi-jvb-server"
    propagate_at_launch = true
  }
}

resource "aws_lb" "jvb" {
  name               = "jitsi-jvb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_connections_jitsi.id]
  subnets            = [aws_default_subnet.default.id, aws_default_subnet.default2.id]
}

resource "aws_lb_listener" "jvb_listener" {
  load_balancer_arn = aws_lb.jvb.arn
  port              = 443     # Assuming Jitsi jvb uses HTTPS on port 443
  protocol          = "HTTPS" # Assuming Jitsi jvb uses HTTPS

  ssl_policy = "ELBSecurityPolicy-2016-08" # Use an appropriate SSL policy

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Jitsi jvb is being prepared. Please try again in a moment."
      status_code  = "503"
    }
  }
}

resource "aws_lb_target_group" "jvb_target_group" {
  name     = "jvb-target-group"
  port     = 443     # Assuming Jitsi jvb uses HTTPS on port 443
  protocol = "HTTPS" # Assuming Jitsi jvb uses HTTPS
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "jvb_target_attachment" {
  count            = length(aws_autoscaling_group.jvb)
  target_group_arn = aws_lb_target_group.jvb_target_group.arn
  target_id        = aws_autoscaling_group.jvb[count.index].id
}

resource "aws_lb_listener_rule" "jvb_listener_rule" {
  listener_arn = aws_lb_listener.jvb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jvb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_route53_record" "jvb" {
  count   = length(aws_autoscaling_group.jvb)
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${var.aws_region}-jvb${count.index}.${var.parent_subdomain}"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.jvb.dns_name]
}
