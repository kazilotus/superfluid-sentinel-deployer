
# Superfluid Sentinel Deployer

Welcome to the Superfluid Sentinel Deployer project! This repository contains the code and configurations to deploy and manage infrastructure using Terraform for the Superfluid application. In this document, you will find information on the project structure, workflows, setup instructions, and more.

## Introduction

Superfluid Sentinel Deployer automates the deployment and management of infrastructure for the Superfluid Sentinel. It utilizes Terraform and other tools to set up AWS resources, deploy the Sentinel, and handle its lifecycle. With the help of GitHub Actions workflows, the CI/CD pipeline is streamlined.

## Project Structure

Let's take a look at the structure of the Superfluid Sentinel project:

- `.github/workflows`: This directory contains all the GitHub Actions workflows that define our CI/CD pipeline. Each workflow has a specific purpose, such as infrastructure deployment, image building, and application deployment.
- `terraform`: Here, you'll find the Terraform configuration files and modules used to set up and manage the infrastructure. These files define the AWS resources and their configurations.
- `.github/scripts`: This directory contains Python scripts used by the GitHub Actions workflows. They help us check for existing resources and set up the Terraform backend.

The project is organized in a way that makes it easy to navigate and understand. Now that you know the project structure, let's dive into the workflows.

## Workflow Descriptions

We have several GitHub Actions workflows that handle different tasks in our CI/CD pipeline. Here's an overview of each workflow:

1. `0.init.yml`: This workflow sets up the Terraform backend by creating the necessary AWS S3 bucket and DynamoDB table. It ensures we have a centralized location to store and manage the Terraform state.
2. `1.check.yml`: The purpose of this workflow is to check if there's a Terraform state lock. It determines whether infrastructure deployment is needed and triggers the appropriate workflows accordingly.
3. `2.infra.yml`: This workflow deploys infrastructure using Terraform. It initializes Terraform, plans the deployment, and applies the changes to create the AWS resources defined in our Terraform configuration files.
4. `3a.build.yml`: Here, we build the application's Docker image. We use Nix to build the docker images. The Docker image is then pushed to Amazon ECR for storing.
5. `4.deploy.yml`: This workflow deploys the application image to AWS ECS (Elastic Container Service) by updating the ECS task with the new image. It ensures the latest version of the application is running in the ECS cluster.

Each workflow is designed to perform specific actions in our CI/CD pipeline. Together, they provide an automated and efficient process for managing the infrastructure and deploying the Superfluid Sentinel.

## Setup Instructions

To get started with Superfluid Sentinel Deployer, follow these steps:

1. Make sure you have the necessary AWS credentials and GitHub secrets configured. These credentials will be used to authenticate and interact with AWS services. The required secrets are:

   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
   - `SENTINEL_ENV`: A JSON object containing the environment variables for the Superfluid Sentinel. For example:

   ```json
   {
     "HTTP_RPC_NODE": "https://polygon-rpc.com",
     "PRIVATE_KEY": "3c672cb143835374d5cf0b987358cce8ab20b4a4537f0d08fdf9eb706c577b2b"
   }
   ```
   Full list of variables can be found here https://github.com/superfluid-finance/superfluid-sentinel/blob/master/.env-example

2. Create an S3 bucket and DynamoDB table for Terraform state management. You can use the `0.init.yml` workflow to automatically set them up. Make sure to set the `TF_BUCKET_NAME` and `TF_TABLE_NAME` environment variables in the workflow file.

3. Customize the Terraform configuration files in the `terraform` directory to match your specific requirements. Adjust the AWS resources, network settings, and any other configurations as needed. Please note, the current CPU and Memory is set to 256 and 512 respectively, this must be modified to get the sentinel started.

4. Customize the environment variables and Docker image configuration in the workflows to align with your needs. Update the values in the workflow files (`2.infra.yml`, `3a.build.yml`, and `4.deploy.yml`) as necessary.

5. Commit and push your changes to the repository. GitHub Actions will automatically trigger the appropriate workflows based on the defined triggers.

6. Sit back and watch as the CI/CD pipeline deploy the infrastructure and the sentinel.

## Cleaning Up

If you decide to no longer use Superfluid Sentinel and want to clean up the resources, follow these steps:

1. Manually run the `-1.destroy.yml` workflow via GitHub Actions. This workflow is specifically designed to destroy all the resources created by Terraform.

2. The workflow will handle the cleanup process and remove the AWS resources associated with your Superfluid application.

Please exercise caution when running the destroy workflow, as it permanently deletes the infrastructure. Make sure you no longer need the resources before initiating the destruction process.

## TODO

Here are some areas for improvement and future enhancements in the Superfluid Sentinel project:

1. Centralize all environment variables used in the workflows to ensure consistency and easier management.

2. Create GitHub variables that can dynamically determine the size of the container, allowing for more flexibility in deployment configurations.

3. Implement the ability to selectively delete or run the entire deployment process based on a specific environment. This will provide more control and flexibility in managing different deployment scenarios.

4. Improve the Nix build file (`build.nix`) to enhance the build process and optimize the Docker image generation. Explore potential optimizations or alternative approaches to enhance performance and reliability.

5. Make the Terraform modules more modular and cloud-agnostic. Refactor the modules to abstract away cloud-specific details, making it easier to switch between different cloud providers if needed.

6. Consider mapping the Sentinel environment variables to AWS Parameter Store or encrypted AWS Systems Manager (SSM) parameters instead of directly loading them into environment variables. This adds an additional layer of security and allows for easier management of sensitive information.

7. Aim to make every module cloud-agnostic to ensure portability. By abstracting cloud-specific details and dependencies, the project can be easily adapted to work with different cloud providers.

8. Modify the `-1.destroy.yml` workflow to include the deletion of the Terraform state backend table and DynamoDB lock. This ensures a complete cleanup of resources associated with Superfluid Sentinel.

9. Implement a scheduled workflow to periodically delete old and unused ECR images. This will help manage storage costs and maintain a clean image repository.

These tasks and improvements will enhance the functionality, scalability, and security of the Superfluid Sentinel project. Contributions and ideas for these enhancements are welcome!