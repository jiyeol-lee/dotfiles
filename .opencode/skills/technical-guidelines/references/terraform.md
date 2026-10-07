# Terraform convention

These are the convention when you write terraform code. You MUST OBEY the following rules.

1. Prefer to use `data` block when defining policy.

Example:

Do it like this:

```tf
data "aws_iam_policy_document" "infrastructure_state" {
  statement {
    ...
  }
}

resource "aws_s3_bucket_policy" "infrastructure_state" {
  bucket = aws_s3_bucket.infrastructure_state.id
  policy = data.aws_iam_policy_document.infrastructure_state.json
}
```

Not like this:

```tf
resource "aws_s3_bucket_policy" "infrastructure_state" {
  bucket = aws_s3_bucket.infrastructure_state.id

  policy = jsonencode({
    ...
  })
}
```
