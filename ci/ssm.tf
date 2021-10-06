data "aws_ssm_parameter" "csls-broker-username" {
  name = "/codepipeline/${var.pipeline_name}/csls-broker-username"
}

data "aws_ssm_parameter" "csls-broker-password" {
  name = "/codepipeline/${var.pipeline_name}/csls-broker-password"
}

data "aws_ssm_parameter" "cf_username" {
  name = "/codepipeline/${var.pipeline_name}/cf-username"
}

data "aws_ssm_parameter" "cf_password" {
  name = "/codepipeline/${var.pipeline_name}/cf-password"
}