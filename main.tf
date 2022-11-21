/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_id" "random_suffix" {
  byte_length = 4
}

resource "google_project_service" "project_services" {
  project                    = var.project_id
  count                      = var.enable_apis ? length(var.activate_apis) : 0
  service                    = element(var.activate_apis, count.index)
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services
}

module "no_service_account_keys" {
  source      = "terraform-google-modules/org-policy/google"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "iam.disableServiceAccountKeyCreation"
  policy_type = "boolean"
  enforce     = true
}


resource "google_service_account" "wif" {
  project      = var.project_id
  account_id   = "${var.environment}-${random_id.random_suffix.hex}"
  display_name = "${var.environment}-${random_id.random_suffix.hex}"
}

resource "google_iam_workload_identity_pool" "pool" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = "${var.pool_id}-${random_id.random_suffix.hex}"
  display_name              = var.pool_display_name
  description               = var.pool_description
  disabled                  = var.pool_disabled
}

resource "google_iam_workload_identity_pool_provider" "idp_provider" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = google_iam_workload_identity_pool.pool.workload_identity_pool_id

  workload_identity_pool_provider_id = "${var.provider_id}-${random_id.random_suffix.hex}"
  display_name                       = var.provider_display_name
  description                        = var.provider_description
  disabled                           = var.provider_disabled

  attribute_mapping   = var.attribute_mapping
  attribute_condition = var.attribute_condition
  oidc {
    allowed_audiences = var.allowed_audiences
    issuer_uri        = var.issuer_uri
  }

}

data "google_iam_policy" "wif" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "principal://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/subject/${var.subject}",
    ]
  }
}


resource "google_service_account_iam_policy" "admin-account-iam" {
  service_account_id = google_service_account.wif.name
  policy_data        = data.google_iam_policy.wif.policy_data
}


resource "google_project_iam_member" "binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.wif.email}"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "null_resource" "create_creds" {
  provisioner "local-exec" {
    command = <<EOF
    gcloud iam workload-identity-pools create-cred-config \
    projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.idp_provider.workload_identity_pool_provider_id} \
    --service-account=${google_service_account.wif.email} \
    --output-file=/tmp/sts.json \
    --credential-source-type=json \
    --credential-source-file=/tmp/okta-token.json \
    --credential-source-field-name=access_token
    EOF
  }
}
