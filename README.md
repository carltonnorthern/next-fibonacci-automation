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

## Design

Terraform is the logical choice of automation tooling to create and manage cloud infrastructure. Cloud Formation can be used when dealing with AWS but it creates lock-in to AWS. Using a Terraform provisioner is sub-optimal for the configuration management of the EC2 instance itself and something like Chef or Puppet would be a much better option. Terraform provisioners are imperative whereas Terraform is a declarative language. This presents potential issues of lifecycle incompatibilities. However, the added complexity of setting up the infrastructure to use these Puppet/Chef was not warranted when Terraform is already in use. The Terraform provisioner works well enough for this scenario.

A better option would be to not use EC2 for this and instead use ECR or EKS, both could be managed with Terraform without requiring the use of a provisioner and without the overhead and lack of auto-scailing ability of an EC2 instance.

Terraform creates a VPC with a private and public subnet. The private subnet isn't actually used but it could have been if we put the application server on another EC2 instance. An internet gateway is created and routed to the public subnet. Then a security group is created which allows unfettered egress and but restricts ingress to ports 22 and 80. Further restricting IP address range on port 22 would be a good idea to improve security in a future release. The EC2 instance of Ubuntu 22.04 is created in the public subnet and the security group is applied to it. An AWS key pair is assigned to it which allows the Terraform provisioner to connect over SSH where it then deploys the [deployment.sh](./deployment.sh) script and executes it. That script configures the Ubuntu instance, namely by installing Docker, and clones the Next Fibonacci repo, where it then runs the docker-compose file which brings up the Nginx reverse proxy and builds the application server container and runs it.
