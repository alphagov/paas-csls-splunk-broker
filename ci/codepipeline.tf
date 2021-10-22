resource "aws_codepipeline" "paas-csls-splunk-broker" {
  name     = var.pipeline_name
  role_arn = data.aws_iam_role.pipeline_role.arn
  tags     = merge(local.tags, { Name = var.pipeline_name })

  artifact_store {
    type     = "S3"
    location = data.aws_s3_bucket.artifact_store.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["paas_csls_splunk_broker"]
      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:connection/${var.codestar_connection_id}"
        FullRepositoryId = "alphagov/paas-csls-splunk-broker"
        BranchName       = "ce-312"
      }
    }

    action {
      name             = "TechOpsRepo"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tech_ops"]
      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:connection/${var.codestar_connection_id}"
        FullRepositoryId = "alphagov/tech-ops"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildZips"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      input_artifacts  = ["paas_csls_splunk_broker"]
      output_artifacts = ["built_zips"]

      configuration = {
        PrimarySource        = "paas_csls_splunk_broker"
        ProjectName          = aws_codebuild_project.codebuild_build.name
        EnvironmentVariables = jsonencode([{ "name" : "CHECK_TRIGGER", "value" : 1 }, { "name" : "ACTION_NAME", "value" : "Deploy" }])
      }
    }
  }

  stage {
    name = "DeployAndTestStaging"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      input_artifacts = ["paas_csls_splunk_broker", "built_zips"]

      configuration = {
        PrimarySource = "paas_csls_splunk_broker"
        ProjectName   = module.codebuild-terraform-staging.project_name
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "TF_VAR_target_deployer_role_arn",
              "value" : "arn:aws:iam::103495720024:role/CodePipelineDeployerRole_103495720024"
            },
            {
              "name" : "TF_VAR_target_zone_name",
              "value" : "staging.gds-cyber-security.digital."
            },
            {
              "name" : "TF_VAR_target_deployment_name",
              "value" : "test"
            },
            {
              "name" : "TF_VAR_csls_deployer_role_arn",
              "value" : "arn:aws:iam::885513274347:role/CodePipelineDeployerRole_885513274347"
            },
            {
              "name" : "TF_VAR_csls_stream_name",
              "value" : "csls_data_stream_prod"
            },
            {
              "name" : "TF_VAR_csls_broker_username",
              "value" : data.aws_ssm_parameter.csls-broker-username.value
            },
            {
              "name" : "TF_VAR_csls_broker_password",
              "value" : data.aws_ssm_parameter.csls-broker-password.value
            },
            {
              "name" : "TF_VAR_cf_username",
              "value" : data.aws_ssm_parameter.cf_username.value
            },
            {
              "name" : "TF_VAR_cf_password",
              "value" : data.aws_ssm_parameter.cf_password.value
            },
            {
              "name" : "TF_VAR_cf_org",
              "value" : "gds-security"
            },
            {
              "name" : "TF_VAR_cf_space",
              "value" : "cyber-sec-sandbox"
            },
            {
              "name" : "TF_VAR_adapter_zip_path",
              "value" : "adapter.zip"
            },
            {
              "name" : "TF_VAR_broker_zip_path",
              "value" : "broker.zip"
            },
            {
              "name" : "TF_VAR_stub_zip_path",
              "value" : "stub.zip"
            },
          ]
        )
      }
    }

    action {
      name            = "EndToEndTestStaging"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      input_artifacts = ["tech_ops"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_staging_test.name
      }
    }
  }

  stage {
    name = "DeployAndTestProd"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      input_artifacts = ["paas_csls_splunk_broker", "built_zips"]

      configuration = {
        PrimarySource = "paas_csls_splunk_broker"
        ProjectName   = module.codebuild-terraform-prod.project_name
        EnvironmentVariables = jsonencode(
          [
            {
              "name" : "TF_VAR_target_deployer_role_arn",
              "value" : "arn:aws:iam::885513274347:role/CodePipelineDeployerRole_885513274347"
            },
            {
              "name" : "TF_VAR_target_zone_name",
              "value" : "csls.gds-cyber-security.digital."
            },
            {
              "name" : "TF_VAR_target_deployment_name",
              "value" : "prod"
            },
            {
              "name" : "TF_VAR_csls_deployer_role_arn",
              "value" : "arn:aws:iam::885513274347:role/CodePipelineDeployerRole_885513274347"
            },
            {
              "name" : "TF_VAR_csls_stream_name",
              "value" : "csls_data_stream_prod"
            },
            {
              "name" : "TF_VAR_csls_broker_username",
              "value" : data.aws_ssm_parameter.csls-broker-username.value
            },
            {
              "name" : "TF_VAR_csls_broker_password",
              "value" : data.aws_ssm_parameter.csls-broker-password.value
            },
            {
              "name" : "TF_VAR_cf_username",
              "value" : data.aws_ssm_parameter.cf_username.value
            },
            {
              "name" : "TF_VAR_cf_password",
              "value" : data.aws_ssm_parameter.cf_password.value
            },
            {
              "name" : "TF_VAR_cf_org",
              "value" : "gds-security"
            },
            {
              "name" : "TF_VAR_cf_space",
              "value" : "cyber-sec-sandbox"
            },
            {
              "name" : "TF_VAR_adapter_zip_path",
              "value" : "adapter.zip"
            },
            {
              "name" : "TF_VAR_broker_zip_path",
              "value" : "broker.zip"
            },
            {
              "name" : "TF_VAR_stub_zip_path",
              "value" : "stub.zip"
            },
          ]
        )
      }
    }

    action {
      name            = "EndToEndTestProd"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 2
      input_artifacts = ["tech_ops"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_prod.name
      }
    }
  }
}
