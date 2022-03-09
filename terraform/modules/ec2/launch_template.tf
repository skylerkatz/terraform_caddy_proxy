data "template_file" "user_data_proxy" {
  template = file("${path.module}/scripts/user-data.tpl")

  vars = {
    infra_env     = var.infra_env
    infra_role    = var.infra_role
    infra_project = var.infra_project
  }
}
resource "aws_launch_template" "launch_template" {
  name_prefix            = "caddy-${var.infra_role}-${var.infra_env}-"
  image_id               = var.instance_ami
  instance_type          = var.instance_size
  user_data              = base64encode(data.template_file.user_data_proxy.rendered)
  vpc_security_group_ids = var.security_groups
  key_name               = "caddy-proxy-${var.infra_env}"
  update_default_version = true

  tags = merge({
    "Name"        = "caddy-lt-${var.infra_env}",
    "Environment" = var.infra_env
    "Project"     = var.infra_project,
    "ManagedBy"   = "terraform",
    "Role"        = var.infra_role
  }, var.launch_template_tags)

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      "Name"        = "caddy-${var.infra_env}",
      "Environment" = var.infra_env
      "Project"     = var.infra_project,
      "ManagedBy"   = "terraform",
      "Role"        = var.infra_role
    }, var.instance_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({
      "Name"        = "caddy-volume-${var.infra_env}",
      "Environment" = var.infra_env
      "Project"     = var.infra_project,
      "ManagedBy"   = "terraform",
      "Role"        = var.infra_role
    }, var.volume_tags)
  }
}
