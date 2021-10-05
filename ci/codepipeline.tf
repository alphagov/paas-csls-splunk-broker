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
        BranchName       = "main"
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
        PrimarySource = "paas_csls_splunk_broker"
        ProjectName   = aws_codebuild_project.codebuild_build.name
        EnvironmentVariables = jsonencode([{ "name" : "CHECK_TRIGGER", "value" : 1 }, { "name" : "ACTION_NAME", "value" : "Deploy" }])
      }
    }
  }
}