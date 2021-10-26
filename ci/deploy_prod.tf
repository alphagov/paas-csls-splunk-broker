module "codebuild-terraform-prod" {
  source                      = "github.com/alphagov/cyber-security-shared-terraform-modules//codebuild/codebuild_apply_terraform"
  codebuild_service_role_name = var.pipeline_role_name
  deployment_account_id       = var.pipeline_account
  deployment_role_name        = var.pipeline_role_name
  terraform_directory         = "terraform"
  codebuild_image             = var.base_image
  pipeline_name               = var.pipeline_name
  environment                 = "prod"
  docker_hub_credentials      = var.docker_hub_credentials
  backend_var_file            = "prod-backend.tfvars"
  terraform_version           = "0.12.24"
  stage_name                  = "DeployAndTestProd"
  copy_artifacts = [
    {
      "artifact" : "built_zips"
      "source" : "adapter.zip"
      "target" : "terraform"
    },
    {
      "artifact" : "built_zips"
      "source" : "broker.zip"
      "target" : "terraform"
    },
    {
      "artifact" : "built_zips"
      "source" : "stub.zip"
      "target" : "terraform"
    }
  ]
}
