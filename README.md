## Pipeline Overview
![CI Pipeline Diagram](ci-pipeline-diagram.png)

## Guide
> Note: Use `chmod +x ./scripts/symlink_modules.sh` and `./scripts/symlink_modules.sh` to create a symlinked default/ folder

### Set up and create infra on a new environment
1. Create a new AWS account
2. Create a new IAM bootstrap user and add [this](bootstrap/README.md) as inline policy
3. Enable `Allow GitHub Actions to create and approve pull requests` in Github Actions -> General (if you're using the `ad-m/github-push-action@master` step)
4. Set up a new repository environment in Github
5. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets in the repository environment
6. Create a new branch and make sure the name of the branch is the same as the name of the repository environment
7. Push changes to new branch
8. Done

### Destroy infra for an environment
1. Run Destroy Infrastructure workflow manually in Github Actions
2. (Optional: Remove bootstrap setup) Delete the `s3` terraform state bucket (and the contents inside it) and the `dynamodb table` + IAM resources: `terraform-execution-role`, `terraform-base-policy` and `Identity Provider`
3. Done

### Set up Cloudflare
1. Create a Cloudflare account
2. Add your domain name and make sure DNS records are empty and you have added the cloudflare nameservers to your domain register
3. Retrieve your API token at your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) and add `CLOUDFLARE_API_TOKEN` to your environment secret.
4. Done

### Project Structure
| Path                                 | Description                                                                                                                                                                                                                                                                                                   |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| .github/workflows/bootstrap.yml      | Sets up initial infrastructure (tf backend, oidc, terraform-execution role, etc.) for a new environment                                                                                                                                                                                                       |
| .github/workflows/deploy.yml         | Deploys infrastructure in 2 steps; iam -> resources. Environment is branch based. TF_VARS are defined here                                                                                                                                                                                                    |
| .github/workflows/destroy.yml        | Destroys infrastructure in 2 steps; resources -> iam. Can only be dispatched throught GHA. If `tf-rm` is specified it will only delete a specific resource from the state bucket and not perform a destroy operation                                                                                          |
| .vscode/settings.json                | Project settings                                                                                                                                                                                                                                                                                              |
| apps/                                | Directory where all apps and services are defined                                                                                                                                                                                                                                                             |
| apps/app_name/iam_deploy.tf          | Create role with necessary IAM permissions for deploying the app                                                                                                                                                                                                                                              |
| apps/app_name/main.tf                | App infrastructure defined here                                                                                                                                                                                                                                                                               |
| apps/app_name/outputs.tf             | Every app which has aws resources needs to output a policy_document to the root (main.tf) file                                                                                                                                                                                                                |
| apps/app_name/variables.tf           | Variables from the common module                                                                                                                                                                                                                                                                              |
| bootstrap/setup-backend/             | Bootstraps backend state (s3 + dynamodb)                                                                                                                                                                                                                                                                      |
| bootstrap/setup-oidc/                | Sets up terraform-execution-role and OIDC so deploy and destroy can be executed                                                                                                                                                                                                                               |
| common/                              | Common infrastructure                                                                                                                                                                                                                                                                                         |
| globals/                             | Global module that can be imported in other modules. Prevents "prop drilling". This module reads from globals.json that gets generated in CI workflow                                                                                                                                                         |
| iam_policy/                          | Combines multiple policy documents into one policy                                                                                                                                                                                                                                                            |
| modules/                             | Cloud resources                                                                                                                                                                                                                                                                                               |
| modules/module_name/iam              | Creates and outputs policy document dynamically based on resource and input variables                                                                                                                                                                                                                         |
| modules/module_name/resources        | Resources are defined here                                                                                                                                                                                                                                                                                    |
| modules/module_name/variables.tf     | Variables which are symlinked into resources/ and iam/ when running                                                                                                                                                                                                                                           |
| modules/module_name/default (HIDDEN) | After running ./symlink_modules.sh a hidden default/ folder will be created and contain symlinked resources/ and variables.tf. This is done so modules can be called with a static path ./path/to/module_name/default. The CI workflow symlinks iam/ or resources/ to default/ based on current workflow_step |
| create_globals.py                    | Used in CI workflows to generate globals.json                                                                                                                                                                                                                                                                 |
| main.tf                              | Terraform entry file for deploy.yml and destroy.yml                                                                                                                                                                                                                                                           |
| retry_command.sh                     | Used in CI workflows to retry terraform commands                                                                                                                                                                                                                                                              |
| symlink_modules.sh                   | First it creates variables.tf inside iam/ and resource/ for every module. Then it creates a default/ folder that points to either iam/ or resource/                                                                                                                                                           |
| terraform_show.json (in branch: terraform-state)                  | Generated by the CI workflows and has the current state of the infrastructure in json format. Its fetched from this repo in this project https://github.com/carlssonk/terraform-diagram                                                                                                                       |
| variables.tf                         | Terraform entry variables for deploy.yml and destroy.yml                                                                                                                                                                                                                                                      |


### Security Measures Checklist
If using NAT Gateway
- [ ] ~~Should place resources in private subnets when possible~~
- [ ] ~~Should have Load Balancer in private subnet if using a CDN on top of it, else it should be public~~
- [ ] ~~Should have ECS services in private subnet if using a Load Balancer on top of ir, else it should be public~~

If NOT using NAT Gateway
- [ ] Should place resource in privat subnets when possible while keeping it robust and scalable
- [ ] Should have Load Balancer in a public subnet (its technically possible to have it in private subnet but its too much management overhead and isn't robust)
- [ ] Should have ECS services in private subnets if using Load Balancer on top of it AND it doesnt need to make outbound requests (API calls, Websockets etc.)

### Potential Cost Optimizations
* Use fck-nat in replacement for NAT Geteway
* Private IPv4 addresses associated with a running instance are free. But public IPv4 addresses it costs $0.005 per hour per associated service
* IPv6 addresses are free
* fck-nat or VPC Endpoints (if applicable) might be cheaper than having lots of services in public subnets
* NAT Gateway is not needed when using IPv6. aws_egress_only_internet_gateway is free and handles IPv6 traffic only, should be used for private services


Example Architecture Overview with NAT Gateway
IPv4 addresses
Cloudflare -> Load Balancer (public subnets) -> Services (private subnets) -> NAT Gateway (public subnets) -> Internet
IPv6 addresses
Cloudflare -> Load Balancer (public subnets) -> Services (no need for public/private distinciton) -> Egress-only Internet Gateway -> Internet

Debug ec2 instance: 
cat /var/log/cloud-init-output.log
cat /var/log/cloud-init.log