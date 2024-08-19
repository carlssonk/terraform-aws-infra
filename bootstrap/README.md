## Bootstrap user IAM policy

Replace `ENVIRONMENT` with your environment (same as branch name and repo environment)

> If you're using this terraform config in another repository, you also need to replace `carlssonk` with your organization name

> If you're using another region than `eu-north-1` it also needs to be replaced

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateS3BucketForTerraformBackend",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:ListBucket",
                "s3:Get*",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::carlssonk-terraform-state-bucket-ENVIRONMENT",
                "arn:aws:s3:::carlssonk-terraform-state-bucket-ENVIRONMENT/*"
            ]
        },
        {
            "Sid": "CreateDynamoDBTableForTerraformBackend",
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeTable",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTagsOfResource"
            ],
            "Resource": "arn:aws:dynamodb:eu-north-1:*:table/carlssonk-terraform-lock-table-ENVIRONMENT"
        },
        {
            "Sid": "IAMOpenIdConnectProviderAndTerraformExecutionRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateOpenIDConnectProvider",
                "iam:DeleteOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "iam:UpdateOpenIDConnectProviderThumbprint",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:UpdateRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies"
            ],
            "Resource": [
                "arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com",
                "arn:aws:iam::*:role/terraform-execution-role"
            ]
        },
        {
            "Sid": "IAMSelfUpdatePolicyForTerraformExecutionRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:DeletePolicy",
                "iam:ListPolicyVersions"
            ],
            "Resource": "arn:aws:iam::*:policy/terraform-self-update-policy"
        },
        {
            "Sid": "IAMPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/terraform-execution-role",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```