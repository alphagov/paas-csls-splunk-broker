resource "aws_codebuild_project" "codebuild_build" {
  name        = "codepipeline-${var.pipeline_name}-build"
  description = "Build various zip files for the CSLS Splunk broker"

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
    image                       = "golang:1.13"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false

    registry_credential {
      credential_provider = "SECRETS_MANAGER"
      credential          = data.aws_secretsmanager_secret.dockerhub_creds.arn
    }

    environment_variable {
      name  = "CGO_ENABLE"
      value = 0
    }

    environment_variable {
      name  = "GOOS"
      value = "linux"
    }

    environment_variable {
      name  = "GOARCH"
      value = "amd64"
    }

    environment_variable {
      name  = "DEBIAN_FRONTEND"
      value = "noninteractive"
    }

  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/codebuild-build.yml")
  }

}
