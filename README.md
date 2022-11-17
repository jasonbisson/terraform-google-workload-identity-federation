# terraform-google-workload-identity-federation

This module will will deploy a Workload Identity Pool, Provider, and Service Account that will be impersonated by an external identity. In addition a script is available to generate a OIDC token to run through the token exchange dance.

The resources/services/activations/deletions that this module will create/trigger are:

- Create a Workload Identity Pool
- Create a Workload Identity Provider
- Create a Service Account 
- Update IAM Policy to Impersonate an external Identity via attributes/claims

## Usage

Basic usage of this module is as follows:

```hcl
module "workload_identity_federation" {
  source  = "terraform-google-modules/workload-identity-federation/google"
  version = "~> 0.1"


}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | The list of apis to activate for Cloud Function | `list(string)` | <pre>[<br>  "sts.googleapis.com",<br>  "iamcredentials.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "iam.googleapis.com"<br>]</pre> | no |
| allowed\_audiences | Workload Identity Pool Provider allowed audiences | `list(string)` | `[]` | no |
| attribute\_condition | Workload Identity Pool Provider attribute condition expression | `string` | `null` | no |
| attribute\_mapping | Workload Identity Pool Provider attribute mapping | `map(any)` | n/a | yes |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_dependent_services | `string` | `"false"` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy | `string` | `"false"` | no |
| enable\_apis | Whether to actually enable the APIs. If false, this module is a no-op. | `string` | `"true"` | no |
| environment | Unique environment name to link the deployment together | `any` | n/a | yes |
| issuer\_uri | Workload Identity Pool Provider issuer URL | `string` | n/a | yes |
| pool\_description | Workload Identity Pool description | `string` | `"Workload Identity Pool managed by Terraform"` | no |
| pool\_disabled | Workload Identity Pool disabled | `bool` | `false` | no |
| pool\_display\_name | Workload Identity Pool display name | `string` | `null` | no |
| pool\_id | Workload Identity Pool ID | `string` | n/a | yes |
| project\_id | Google Cloud Project where Identity pool will be deployed | `any` | n/a | yes |
| provider\_description | Workload Identity Pool Provider description | `string` | `"Workload Identity Pool Provider managed by Terraform"` | no |
| provider\_disabled | Workload Identity Pool Provider disabled | `bool` | `false` | no |
| provider\_display\_name | Workload Identity Pool Provider display name | `string` | `null` | no |
| provider\_id | Workload Identity Pool Provider ID | `string` | n/a | yes |
| subject | External subject to impersonate Service Account | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
