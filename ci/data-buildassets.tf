# The CodeBuild test projects connect to Splunk. These connections time out because of how the
# allow listing works on Splunk. For this reason we have created a VPC, whose IP we can add to the
# Splunk allow list.
data "terraform_remote_state" "build_vpc" {
  backend = "s3"
  config = {
    bucket  = "gds-security-terraform"
    key     = "terraform/state/account/${data.aws_caller_identity.current.account_id}.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

data "aws_iam_role" "pipeline_role" {
  name = var.pipeline_role_name
}

data "aws_s3_bucket" "artifact_store" {
  bucket = "co-cyber-codepipeline-artifact-store"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "dockerhub_creds" {
  name = var.docker_hub_credentials
}
