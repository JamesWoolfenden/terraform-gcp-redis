# terraform-gcp-redis

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-redis/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-redis)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-redis.svg)](https://github.com/JamesWoolfenden/terraform-gcp-redis/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-redis.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-redis/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)

## Usage

Security controls enforced by the module (not configurable):

- AUTH enabled
- In-transit TLS (`SERVER_AUTHENTICATION`)
- Customer-managed encryption key is **required**

### Direct Peering

```hcl
module "redis" {
  source  = "JamesWoolfenden/redis/gcp"
  version = "0.2.0"

  cache = {
    name                    = "my-cache"
    memory_size_gb          = 1
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = google_compute_network.app.id
    redis_version           = "REDIS_7_2"
    customer_managed_key    = google_kms_crypto_key.redis.id
    reserved_ip_range       = "10.0.0.0/29"  # optional
  }
  region = "us-central1"
}
```

### Private Service Access

PSA requires a `google_compute_global_address` and `google_service_networking_connection`
to be created by the caller. Both are VPC-level singletons — if other PSA-enabled services
share the same network they must reuse the same connection.

```hcl
resource "google_compute_global_address" "psa" {
  name          = "redis-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.app.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.app.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}

module "redis" {
  source  = "JamesWoolfenden/redis/gcp"
  version = "0.2.0"

  cache = {
    name                    = "my-cache"
    memory_size_gb          = 1
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = google_compute_network.app.id
    redis_version           = "REDIS_7_2"
    connect_mode            = "PRIVATE_SERVICE_ACCESS"
    reserved_ip_range       = google_compute_global_address.psa.name
    customer_managed_key    = google_kms_crypto_key.redis.id
  }
  region = "us-central1"

  depends_on = [google_service_networking_connection.psa]
}
```

### With maintenance window, persistence, and read replicas

```hcl
module "redis" {
  source  = "JamesWoolfenden/redis/gcp"
  version = "0.2.0"

  cache = {
    name                    = "my-cache"
    memory_size_gb          = 4
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = google_compute_network.app.id
    redis_version           = "REDIS_7_2"
    customer_managed_key    = google_kms_crypto_key.redis.id
    read_replicas_mode      = "READ_REPLICAS_ENABLED"
    replica_count           = 1

    redis_configs = {
      maxmemory-policy = "allkeys-lru"
    }

    maintenance_policy = {
      day     = "SUNDAY"
      hours   = 2
      minutes = 0
    }

    persistence_config = {
      persistence_mode    = "RDB"
      rdb_snapshot_period = "TWELVE_HOURS"
    }
  }
  region = "us-central1"
}
```

## Auth

```bash
gcloud auth application-default login --project yourproj
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_redis_instance.pike](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cache"></a> [cache](#input\_cache) | Configuration for the Cloud Memorystore Redis instance | <pre>object({<br/>    name                    = string<br/>    memory_size_gb          = number<br/>    tier                    = string<br/>    location_id             = string<br/>    alternative_location_id = optional(string)<br/>    authorized_network      = string<br/>    redis_version           = string<br/>    display_name            = optional(string)<br/>    reserved_ip_range       = optional(string)<br/>    customer_managed_key    = string<br/>    connect_mode            = optional(string)<br/>    replica_count           = optional(number)<br/>    read_replicas_mode      = optional(string)<br/>    redis_configs           = optional(map(string), {})<br/>    maintenance_policy = optional(object({<br/>      day     = string<br/>      hours   = number<br/>      minutes = number<br/>    }))<br/>    persistence_config = optional(object({<br/>      persistence_mode    = string<br/>      rdb_snapshot_period = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy the Redis instance in | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_auth_string"></a> [auth\_string](#output\_auth\_string) | The AUTH string for the Redis instance |
| <a name="output_host"></a> [host](#output\_host) | The IP address of the Redis instance |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Redis instance |
| <a name="output_port"></a> [port](#output\_port) | The port number of the Redis instance |
| <a name="output_redis"></a> [redis](#output\_redis) | The full Redis instance resource |
| <a name="output_server_ca_certs"></a> [server\_ca\_certs](#output\_server\_ca\_certs) | CA certificates for TLS verification |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Information

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang

resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "redis.instances.create",
    "redis.instances.delete",
    "redis.instances.get",
    "redis.instances.update",
    "redis.operations.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-aws-codecommit](https://github.com/jameswoolfenden/terraform-aws-codebuild) - Storing ones code

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues) to report any bugs or file feature requests.

## Copyrights

Copyright � 2023-26 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
