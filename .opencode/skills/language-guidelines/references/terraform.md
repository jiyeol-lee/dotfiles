# Terraform conventions

## General

1. Prefer a dedicated data source to generate a resource's configuration when one is available, instead of hardcoding it inline.

For example, generate policy JSON with `aws_iam_policy_document` and reference it from the resource.

Do it like this:

```tf
data "aws_iam_policy_document" "bucket_access" {
  # Policy statements.
}

resource "aws_s3_bucket_policy" "bucket_access" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.bucket_access.json
}
```

Not like this:

```tf
resource "aws_s3_bucket_policy" "bucket_access" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    # Inline policy.
  })
}
```

2. Define outputs only when they have a consumer.

Do not add outputs just because they might be useful later. Add them when an actual consumer needs them.

```tf
# Child module exposes a value used by the parent.
output "queue_arn" {
  value = aws_sqs_queue.example.arn
}
```

If nothing needs this value outside the module, omit the output.

3. Write lists across multiple lines, even when they contain one item.

Do it like this:

```tf
actions = [
  "sqs:SendMessage",
]
```

Not like this:

```tf
actions = ["sqs:SendMessage"]
```

4. Add tags to every resource that supports them.

Include `iac = "opentofu"` and `repo` set to the current repository's name.

```tf
tags = {
  repo = "my-repository"
  iac  = "opentofu"
}
```

If a resource does not support tags but supports a configurable name, prefix its name with the repository name, using `kebab-case`.

For example, `aws_iam_role_policy` does not support tags. For repository `my-repository`:

```tf
resource "aws_iam_role_policy" "send_orders" {
  name   = "my-repository-send-orders"
  role   = aws_iam_role.application.id
  policy = data.aws_iam_policy_document.send_orders.json
}
```

5. Use `snake_case` for Terraform identifiers and `kebab-case` for AWS resource names.

```tf
resource "aws_sqs_queue" "orders_queue" {
  name = "orders-queue"
}
```

6. For cross-repository outputs, the producing repository owns a single getter module directly at `modules/getter/`, with no named child directory.

```
modules/getter/
├── main.tf
└── output.tf
```

In `main.tf`, define a `terraform_remote_state` data block for the producing repository's state. In `output.tf`, expose all existing root outputs:

```tf
output "values" {
  value = data.terraform_remote_state.network.outputs
}
```

Consumers use the getter module's Git source instead of repeating remote-state blocks:

```tf
module "network" {
  source = "git::https://github.com/example/network.git//modules/getter?ref=<tag, branch, or commit>"
}

locals {
  vpc_id = module.network.values.vpc_id
}
```

7. Prefer Terraform built-in functions when they express intent and constraints more clearly than indexing or equivalent custom expressions. Use them only when their behavior matches the requirement.

For example, use `one()` when expecting a collection to contain a single element, instead of selecting its first element.

Do it like this:

```tf
data "aws_organizations_organization" "this" {}

locals {
  root_id = one(data.aws_organizations_organization.this.roots).id
}
```

Not like this:

```tf
data "aws_organizations_organization" "this" {}

locals {
  root_id = data.aws_organizations_organization.this.roots[0].id
}
```

`one()` returns `null` for an empty collection and raises an error for multiple elements. It does not enforce exactly one element.

## AWS

1. Derive ARN values from the target AWS environment instead of hardcoding them.

Prefer a resource's exported ARN:

```tf
resources = [
  aws_sqs_queue.orders.arn,
]
```

When constructing an ARN manually, use `aws_partition` and `aws_caller_identity` for resources in the provider's account:

```tf
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

# Within a policy statement:
resources = [
  "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/orders-reader",
]
```

If the target resource uses an aliased provider, use that same provider on the data sources:

```tf
data "aws_partition" "production" {
  provider = aws.production
}

data "aws_caller_identity" "production" {
  provider = aws.production
}
```

This queries the production provider's environment instead of the default provider's. For cross-account resources, use the target account's ID rather than the caller's.

2. Grant only the IAM permissions required for the intended operation.

For an application that only sends messages to one queue:

```tf
actions = [
  "sqs:SendMessage",
]
resources = [
  aws_sqs_queue.orders.arn,
]
```

Do not use `sqs:*` or grant access to other queues. Use wildcards only when required, and explain why:

```tf
actions = [
  "sqs:ListQueues",
]
# ListQueues does not support resource-level permissions.
resources = [
  "*",
]
```
