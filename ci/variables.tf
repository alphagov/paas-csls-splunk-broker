variable "pipeline_name" {
  type    = string
  default = "paas-csls-splunk-broker"
}

variable "codestar_connection_id" {
  type    = string
  default = "51c5be90-8c8f-4d32-8be4-18b8f05c802c"
}

variable "docker_hub_credentials" {
  type    = string
  default = "docker_hub_credentials"
}

variable "pipeline_account" {
  type    = string
  default = "670214072732"
}

variable "pipeline_role_name" {
  type    = string
  default = "CodePipelineExecutionRole"
}

variable "base_image" {
  type    = string
  default = "gdscyber/cyber-security-cd-base-image:latest"
}
