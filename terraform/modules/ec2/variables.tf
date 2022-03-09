variable "infra_env" {
  type        = string
  description = "Infrastructure environment"
}

variable "infra_role" {
  type        = string
  description = "Infrastructure purpose"
}

variable "infra_project" {
  type        = string
  description = "The project that the infrastructure belongs to"
  default     = "caddy-proxy"
}

variable "instance_size" {
  type        = string
  description = "The size of the ec2 server"
  default     = "t3.small"
}

variable "instance_ami" {
  type        = string
  description = "Server AMI to use"
}

variable "instance_root_device_size" {
  type        = number
  description = "Root block device size in GB"
  default     = 12
}

variable "asg_subnets" {
  type        = list(string)
  description = "Valid subnets to assign to server"
}

variable "nlb_subnets" {
  type        = list(string)
  description = "Valid subnets to assign to server"
}

variable "vpc_id" {
  type        = string
  description = "The Id of the VPC where the servers are located"
}

variable "asg_max_instances" {
  type        = number
  description = "Maximum number of instances the autoscaling group should have"
  default     = 1
}
variable "asg_min_instances" {
  type        = number
  description = "Minimum number of instances the autoscaling group should have"
  default     = 1
}
variable "asg_desired_instances" {
  type        = number
  description = "The desired number of instances the autoscaling group should have"
  default     = 1
}

variable "security_groups" {
  type        = list(string)
  description = "Security group to assign to server"
  default     = []
}

variable "launch_template_tags" {
  type        = map(string)
  description = "Additional tags to assign to the launch template"
  default     = {}
}

variable "instance_tags" {
  type        = map(string)
  description = "Additional tags to assign to the instance"
  default     = {}
}

variable "volume_tags" {
  type        = map(string)
  description = "Additional tags to assign to the ebs volumes attached to instances"
  default     = {}
}

variable "create_eip" {
  type        = bool
  description = "Whether to create an EIP for the ec2 instance or not"
  default     = false
}
