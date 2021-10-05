locals {
  tags = {
    Service       = "csls-splunk-adapter",
    Environment   = "prod",
    SvcOwner      = "cyber-security",
    DeployedUsing = "Terraform_v12",
    SvcCodeURL    = "https://github.com/alphagov/tech-ops/tree/master/cyber-security/components/csls-splunk-broker"
  }
}