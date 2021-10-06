resource "aws_codebuild_project" "codebuild_create_staging_backend" {
  name           = "codepipeline-${var.pipeline_name}-create-staging-backend"
  description  = "Create a backend.tfvars file for the staging account"

  service_role = data.aws_iam_role.pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"

  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
        name = "BACKEND_BUCKET"
        value = "TODO"
    }

    environment_variable {
        name = "BACKEND_STATE_PATH"
        value = "syslog-http-adapter-test.tfstate"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = file("${path.module}/codebuild-create-backend.yml")
  }
}