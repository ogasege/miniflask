# Tasks

These are the expected tasks to be delivered:

1. Create a minimal API that contains the following two endpoints

    time - outputs current unix timestamp

    random - outputs a list of 10 random numbers (range: 0 to 5)

2. Create a Dockerfile that includes your API and make it runnable as a container.

3. Create a minimal Terraform config that would deploy your container on AWS ECS/Fargate, you may assume the following:

    Your docker image can be uploaded to a public docker registry
    You are given the values of the VPC


# How to run the project:

- The app is written in python and the dependencies are stored in the requirements.txt file

- This is the containerized using the dockerfile in the repository

- The container is then built using the command: 

	`docker build -t miniflask-api .`

- An AWS ECR public repository is used for storing the container image. To do this, an authentication token needs to be retrieved and the Docker client to the registry needs to be authenticated. This is done using  AWS CLI. The CLI needs to be configured with the appropriate credentials:

    `aws configure`

    `aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/g1s5q2a7`

- After the build completes,the image is then pushed to the repository with the image tag as 'latest':

    `docker tag miniflask-api:latest public.ecr.aws/g1s5q2a7/miniflask-api:latest`

    `docker push public.ecr.aws/g1s5q2a7/miniflask-api:latest`

- After the image has been pushed to the repository, the image URL is then retrieved

- The infrastructure required to deploy the container on AWS Fargate is then defined in the main.tf file. Then, the following commands are run:

    `terraform init`  - This initializes Terraform in the project directory.

    `terraform plan`  - This helps validate configuration before deploying.

    `terraform apply` - This deploys the infrastructure in the configured AWS account. 

- After the infrastructure has been deployed, the public IP address of the Fargate instance which hosts the container is gotten. the public IP address in this case is 18.215.160.156.

## API Endpoints
These are the API endpoints:

- Time - http://18.215.160.156:5000/time
- RandomNumbers - http://18.215.160.156:5000/random

### Postman Documentation
The postman documentation can be found here:

[Postman Documentation](https://github.com/ogasege/miniflask/blob/master/MINIFLASK%20API.postman_collection.json)
