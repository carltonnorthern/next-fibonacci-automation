# Next Fibonacci Automation

Terraform automation to deploy the [Next Fibonacci](https://github.com/carltonnorthern/next-fibonacci) codebase to an EC2 instance.

## Description

This repository contains the Terraform code to deploy an AWS VPC, configure it, and then instantiate an EC2 instance that runs the [Next Fibonacci](https://github.com/carltonnorthern/next-fibonacci) service. Set AWS credentials and choose SSH keys to access the EC2 instance and Terraform will do the rest. Once the AWS infrastructure is created a Terraform provisioner deploys the [deployment.sh](./deployment.sh) bash script to the EC2 instance which installs Docker, clones the Next Fibonacci repo, and runs the [docker-compose.yaml](https://github.com/carltonnorthern/next-fibonacci/blob/main/docker-compose.yaml) file.

## Quickstart

1. Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables provided from your AWS account.

2. Create a `terraform.tfvars` file and provide values for the following variables (examples values provided):

    ```properties
    private_ssh_key_file="~/.ssh/id_ed25519"
    public_ssh_key_file="~/.ssh/id_ed25519.pub"
    ssh_key_name="id_ed25519"
    ```

3. Run with normal terraform init, plan, apply, and destroy functions.
