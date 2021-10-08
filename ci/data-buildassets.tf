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