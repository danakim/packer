# Gitlab Runner

The `gitlab-runner.json` file along with the helper scripts (`gitlab-runner-*`) build an AMI that has the Gitlab runner alongside Docker installed. It also adds a simple bash script (`gitlab-runner-provision.sh`) that can be called at the initial boot time of the EC2 instance to register the runner in CR's Gitlab account.

## How to build the Gitlab runner AMI

The AMI needs to be built and pushed to an AWS account from where it can be used by the Terraform code, such as the 'shared' account in a Gruntwork infrastructure.
```
cd gitlab-runner
packer build -var 'aws_access_key=<your_access_key_id>' -var 'aws_secret_key=<your_access_key>' gitlab-runner.json
```

Afterwards go to the AWS console in the shared services account and make sure the image is available to the other accounts following the instructions here: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/sharingamis-explicit.html. Make a note of the AMI ID as you are going to need it later.

## How to use the the Gitlab runner AMI

The AMI should now be available in all the AWS sub-accounts, so when creating a new EC2 instance (either via the console or the CLI or Terraform) you can use the AMI ID to deploy. From the console, choose 'My AMIs' and make sure 'Shared with me' is ticked.

To make sure that the instance you are launching with this AMI registers to Gitlab at the initial startup, make sure to call the following script from the [`User data`](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) section of EC2's instance launch options:

```
/home/ubuntu/gitlab-runner-register.sh <environment (e.g.: dev)> <gitlab_cicd_token>
```
