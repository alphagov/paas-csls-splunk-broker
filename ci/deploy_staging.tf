module "codebuild-terraform-staging" {
  source                      = "github.com/alphagov/cyber-security-shared-terraform-modules//codebuild/codebuild_apply_terraform"
  codebuild_service_role_name = "CodePipelineExecutionRole"
  deployment_account_id       = var.staging_account
  deployment_role_name        = var.staging_deployment_role
  terraform_directory         = "terraform"
  codebuild_image             = "gdscyber/cyber-security-cd-base-image:latest"
  pipeline_name               = var.pipeline_name
  environment                 = "test"
  docker_hub_credentials      = var.docker_hub_credentials
  backend_var_file            = "backend.tfvars"
  terraform_version           = "0.12.24"
  copy_artifacts              = [
      {
        "artifact": "built_zips"
        "source": "adapter.zip"
        "target": "terraform"
      },
      {
        "artifact": "built_zips"
        "source": "broker.zip"
        "target": "terraform"
      },
      {
        "artifact": "built_zips"
        "source": "stub.zip"
        "target": "terraform"
      },
      {
        "artifact": "staging_backend"
        "source": "backend.tfvars"
        "target": "terraform"
      }
  ]
}