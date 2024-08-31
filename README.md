## Guide

### Set up and create infra on a new environment
1. Create a new AWS account
2. Create a new IAM bootstrap user and add [this](bootstrap/README.md) as inline policy
3. Set up a new repository environment in Github
4. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets in the repository environment
5. Create a new branch and make sure the name of the branch is the same as the name of the repository environment
6. Push changes to new branch
7. Done

### Destroy infra for an environment
1. Run Destroy Infrastructure workflow manually in Github Actions
2. Done
3. (Optional additional step) Go to AWS Console and delete the `s3` terraform state bucket (and the contents inside it) and the `dynamodb table`

### Set up Cloudflare for static website hosting
1. Create a Cloudflare account
2. Add your domain name and make sure DNS records are empty and you have added the cloudflare nameservers to your domain register
3. Retrieve your API token at your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) and add `CLOUDFLARE_API_TOKEN` to your environment secret.
4. Done