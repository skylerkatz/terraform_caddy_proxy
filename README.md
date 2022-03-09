# Introduction
This repository holds the Terraform configuration for the `cloud.bible` proxy server infrastructure.

# First Time Setup
- Create a bucket for your terraform state in S3
    - This bucket will hold both your production and staging terraform state
- update `./run` file with the bucket name you created
- Create a dynamodb table for each of your environments for your terraform locking with the following info
    - Table name: Be sure to prepend your table name with `_env`. For example `my_caddy_terraform_production`, `my_caddy_terraform_staging`
    - Partition Key: LockID (string)
- Update `./run` file with the name of the dynamodb table
- Initialize the various terraform directories
```bash
cd terraform
./run staging compute init && ./run staging data init && ./run staging network init
```
- Before you can create the AMI, you will need to initialize some of your infrastructre to set up things like VPC, ect
    - network will create your VPC and related security groups, subnets, ect
    - data will create your dynamo db tables, and the proper IAM user and store them in secret manager so that packer will be able to dynamically pull the proper keys
```bash
cd terraform
./run staging network apply
./run staging data apply
```
- Now that you have a VPC and Dynamo DB configured you can run the packer scripts
```bash
cd packer
packer build -var-file variables.json caddy-staging.json
```
- Once the AMI is available, you can launch your instances
```bash
cd terraform
./run staging compute apply
```

### Notes
I have not figured out a way to automate the downloading of the caddy binary with dynamodb connected so I have to download it manually to get the latest version and put it in the packer directory. The version inside here may be outdated
You can add anything you want tot he servers that will have caddy on them. You can add anything you want to the files in the scripts directory. Either adding them to `base.sh` or their own file. For example, I add datadog to our caddy servers so there is a datadog.sh to encapsulate that logic. If you look in `caddy-staging.json` you will see one of the `provisioners` is the datadog.sh file that passes in environment variables. These provisoners can be added/deleted/modified as needed.
If you modify the provisoners you may need to modify the `terraform/ENV/modules/ec2/scripts/user-data.tpl` file that starts/stops services when the instance is launched from the autoscaling group.
