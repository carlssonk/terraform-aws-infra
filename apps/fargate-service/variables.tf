variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "app_name" {
  description = "Name"
  type        = string
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}

variable "root_domain" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomains. Use 'www' if website is root"
  type        = string
}

variable "container_port" {
  description = "Port of Docker container"
  type        = number
}

variable "github_repo_name" {
  description = "Repository name for deployment policy. '[github name]/[repo name]'"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDS. If you use private subnets and you're not using a NAT gatewat/instance, you need to add VPC endpoints for ECR pull etc."
  type        = list(string)
}

variable "cluster_id" {
  description = "Cluster ID to use"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of Security Group"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "alb_dns_name" {
  description = "Application load balancer DNS name"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of alb listener"
  type        = string
}

variable "alb_listener_rule_priority" {
  description = "Priority for listener rule, must be unique per alb"
  type        = number
}

variable "use_stickiness" {
  description = "Set this to true if you are using websockets or if you need statefulness"
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Set this to true if you dont have a NAT gateway/instance and you need your service to make outbound requests (service must also be in a public subnet in this case)"
  type        = bool
  default     = false
}

variable "fargate_spot_percentage" {
  description = "Percentage of tasks to run on Fargate Spot (0-100). Eg. if you specify 50, 50% of tasks will be run on spot and 50% on On-Demand instances. Spot is cheaper but less stable."
  type        = number
  default     = 0
  validation {
    condition     = var.fargate_spot_percentage >= 0 && var.fargate_spot_percentage <= 100
    error_message = "fargate_spot_percentage must be between 0 and 100."
  }
}

variable "service_discovery_namespace_id" {
  description = "ID of service discovery http namespace"
  type        = string
}

variable "nginx_proxy_public_ip" {
  description = "Static IP address of proxy server"
  type        = string
}
