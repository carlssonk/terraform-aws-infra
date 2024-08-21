## Guide

### Set up and create infra on a new environment
1. Create a new AWS account
2. Create a new IAM user
3. Set up a new repository environment in Github
4. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets in the repository environment
5. Create a new branch and make sure the name of the branch is the same as the name of the repository environment
6. Push changes to new branch
7. Done

### Destroy infra for an environment
For now we can only destroy manually
1. Run `terraform init -backend-config=backend/backend-[environment].hcl`
2. Run `terraform destroy -auto-approve`
3. (Optional) Go to AWS Console and delete the `s3` terraform state bucket (and the contents inside it) and the `dynamodb table`

### [Bootstrap user IAM Policy](bootstrap/README.md)