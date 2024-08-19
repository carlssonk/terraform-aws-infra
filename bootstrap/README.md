## Bootstrap user IAM policy

Replace `ENVIRONMENT` and `AWS_ACCOUNT_ID`

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
            "Resource": "arn:aws:dynamodb:eu-north-1:AWS_ACCOUNT_ID:table/carlssonk-terraform-lock-table-ENVIRONMENT"
        },
        {
            "Sid": "IAMManagement",
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
                "arn:aws:iam::AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com",
                "arn:aws:iam::AWS_ACCOUNT_ID:role/terraform-execution-role"
            ]
        },
        {
            "Sid": "IAMPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::AWS_ACCOUNT_ID:role/terraform-execution-role",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```