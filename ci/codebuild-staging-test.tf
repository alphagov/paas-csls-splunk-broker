resource "aws_codebuild_project" "codebuild_staging_test" {
  name           = "codepipeline-${var.pipeline_name}-staging-test"
  description    = "Test the staging deployment of the CSLS splunk broker"

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
    image                       = "python:3-buster"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false

    registry_credential {
      credential_provider = "SECRETS_MANAGER"
      credential          = data.aws_secretsmanager_secret.dockerhub_creds.arn
    }

    environment_variable {
      name    = "STUB_URL"
      value   = "https://test-csls-stub.cloudapps.digital"
    }

    environment_variable {
      name    = "SPLUNK_USERNAME"
      value   = data.aws_ssm_parameter.csls_concourse_smoketest_splunk_creds_username.value
    }

    environment_variable {
      name    = "SPLUNK_PASSWORD"
      value   = data.aws_ssm_parameter.csls_concourse_smoketest_splunk_creds_password.value
    }

    environment_variable {
      name    = "SPLUNK_HOST"
      value   = "gds.splunkcloud.com"
    }

    environment_variable {
      name    = "SPLUNK_PORT"
      value   = 8089
    }
  }

  vpc_config {
    vpc_id             = data.terraform_remote_state.build_vpc.outputs.shared_vpc_id
    security_group_ids = [data.terraform_remote_state.build_vpc.outputs.shared_vpc_default_security_group_id]
    subnets            = data.terraform_remote_state.build_vpc.outputs.shared_vpc_public_subnets
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = file("${path.module}/codebuild-test.yml")
  }

}
