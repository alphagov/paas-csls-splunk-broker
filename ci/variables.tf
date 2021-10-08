# variable "target_deployment_name" {
#   type        = string
#   default     = "test"
#   description = "Deployment environment/name used to prefix resources to avoid clashes"
# }

# variable "target_deployer_role_arn" {
#   type        = string
#   description = "ARN of the deployment role in target account where we will provision things"
# }

# variable "target_zone_name" {
#   description = "domain name of zone delegated in target account"
#   default     = "staging.gds-cyber-security.digital."
# }

# variable "csls_deployer_role_arn" {
#   type        = string
#   description = "ARN of the deployment role in csls account where the stream lives"
# }

# variable "cf_username" {
#   type = string
# }

# variable "cf_password" {
#   type = string
# }

# variable "cf_org" {
#   type = string
# }

# variable "cf_space" {
#   type = string
# }

# variable "csls_stream_name" {
#   type = string
# }

# variable "csls_broker_username" {
#   type = string
# }

# variable "csls_broker_password" {
#   type = string
# }

variable "pipeline_name" {
  type = string
  default = "paas-csls-splunk-broker"
}

variable "codestar_connection_id" {
  type = string
  default = "51c5be90-8c8f-4d32-8be4-18b8f05c802c"
}

variable "docker_hub_credentials" {
  type = string
  default = "docker_hub_credentials"
}

variable "pipeline_account" {
  type = number
  default = 670214072732
}

variable "pipeline_role_name" {
  type = string
  default = "CodePipelineExecutionRole"
}
