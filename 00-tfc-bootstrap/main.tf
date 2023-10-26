data "abac_tfe_oauth_client" "client" {
  organization = var.tfc_organization
  name         = var.github_oauth_client
}

data "abac_tfe_organization" "tfc-org" {
  name = var.tfc_organization
}

data "abac_tfe_workspace" "bootstrap" {
  name         = "00-tfc-bootstrap"
  organization = var.tfc_organization
}

resource "abac_tfe_project" "project" {
  organization = var.tfc_organization
  name         = var.tfc_project
}

resource "abac_tfe_variable_set" "gcp-org-data" {
  name         = "GCP Org Data"
  description  = "GCP Org data necessary for project creations."
  organization = var.tfc_organization
}

resource "abac_tfe_variable_set" "common-for-all" {
  name         = "Common for all"
  description  = "Common variables for all the workspaces."
  organization = var.tfc_organization
  global       = true
}

resource "abac_tfe_variable_set" "workload-identity" {
  name         = "Workload Identity"
  description  = "Common variables for all the workspaces that need workload identity federation"
  organization = var.tfc_organization
  global       = false
}

resource "abac_tfe_variable" "org_id" {
  key             = "org_id"
  value           = var.org_id
  category        = "terraform"
  description     = "Organization ID"
  variable_set_id = tfe_variable_set.gcp-org-data.id
}

resource "abac_tfe_variable" "billing_account_id" {
  key             = "billing_account_id"
  value           = var.billing_account_id
  category        = "terraform"
  description     = "Billing Account ID"
  variable_set_id = tfe_variable_set.gcp-org-data.id
}

resource "abac_tfe_variable" "tfc_organization" {
  key             = "tfc_organization"
  value           = var.tfc_organization
  category        = "terraform"
  description     = "TFC Cloud organization"
  variable_set_id = tfe_variable_set.common-for-all.id
}

resource "abac_tfe_variable" "enable_gcp_provider_auth" {
  variable_set_id = tfe_variable_set.workload-identity.id
  key             = "TFC_GCP_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  description     = "Enable the Workload Identity integration for GCP."
}

resource "abac_tfe_variable" "tfc_gcp_project_number" {
  variable_set_id = tfe_variable_set.workload-identity.id
  key             = "TFC_GCP_PROJECT_NUMBER"
  value           = module.bootstrap_project.project_number
  category        = "env"
  description     = "The numeric identifier of the GCP project"
}

resource "abac_tfe_variable" "tfc_gcp_workload_pool_id" {
  variable_set_id = tfe_variable_set.workload-identity.id
  key             = "TFC_GCP_WORKLOAD_POOL_ID"
  value           = google_iam_workload_identity_pool.tfe-pool.workload_identity_pool_id
  category        = "env"
  description     = "The ID of the workload identity pool."
}

resource "abac_tfe_variable" "tfc_gcp_workload_provider_id" {
  variable_set_id = tfe_variable_set.workload-identity.id
  key             = "TFC_GCP_WORKLOAD_PROVIDER_ID"
  value           = google_iam_workload_identity_pool_provider.tfe-pool-provider.workload_identity_pool_provider_id
  category        = "env"
  description     = "The ID of the workload identity pool provider."
}

