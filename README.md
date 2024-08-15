# This repo is in progress...

TODO
We will create one aws account per environemnt for all my portfolio projects, we merge these accounts with an AWS organization or AWS Control Tower Factory for terraform.
Per account we only need to create one IAM user that will be used in CI/CD.

Each resource or app will have its own role, that will be assigned to the CICD user during a run.
The roles will be session based so after every CICD run they will be removed from the user.


## Guide

### Create infra on a new environment
1. Create a new GHA workflow file in .github/workflows
2. Add a new backend hcl file in backend/ folder
3. Create a new branch and push changes to that branch
4. Done.

### Destroy infra for an environment
For now we can only destroy manually
1. Run `terraform init -backend-config=backend/backend-[environment].hcl`
2. Run `terraform destroy -auto-approve`
3. (Optional) Go to AWS Console and delete the `s3` terraform state bucket (and the contents inside it) and the `dynamodb table`
