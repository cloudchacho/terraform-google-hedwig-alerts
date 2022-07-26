Hedwig Alerts Terraform module
==============================

[Hedwig](https://cloudchacho.github.io/hedwig/) is an inter-service communication bus that works on AWS and GCP, while keeping things pretty simple and straight forward.

This module provides a custom [Terraform](https://www.terraform.io/) modules for deploying Hedwig infrastructure that
creates infra for monitoring a Hedwig consumer app.

## Usage

```hcl
module "topic-dev-user-updated-v1" {
  source = "cloudchacho/hedwig-topic/google"
  topic  = "dev-user-updated-v1"
}

module "sub-dev-myapp-dev-user-updated" {
  source = "cloudchacho/hedwig-subscription/google"
  topic  = "${module.topic-dev-user-updated-v1.name}"
  name   = "dev-myapp"
}

module "alerts-dev-myapp-dev-user-updated" {
  source = "cloudchacho/hedwig-alerts/google"
  queue  = "dev-myapp"
}
```

If using a single Google project for multiple environments (e.g. dev/staging/prod), ensure that `name` includes your 
environment name.

Please note Google's restrictions (if not followed, errors may be confusing and often totally wrong):
- [Labels](https://cloud.google.com/pubsub/docs/labels#requirements)
- [Resource names](https://cloud.google.com/pubsub/docs/admin#resource_names) 

## Release Notes

[Github Releases](https://github.com/cloudchacho/terraform-google-hedwig-alerts/releases)

## How to publish

Go to [Terraform Registry](https://registry.terraform.io/modules/cloudchacho/hedwig-alerts/google), and 
Resync module.
