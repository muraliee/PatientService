This Terraform module provisions an AWS VPC, ECR repository, ECS cluster, ALB, and an ECS Fargate service for the `patient-service`.

Quick usage:

1. Configure AWS credentials in your environment (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION).
2. Initialize Terraform:

   terraform init

3. Plan and apply:

   terraform plan -out plan.tfplan
   terraform apply plan.tfplan

4. Build and push the container image to ECR:

   cd ../scripts
   ./push-to-ecr.sh <tag>

5. Update the service to use the pushed image (if you didn't set `image_uri` variable):

   terraform apply -var "image_uri=<account>.dkr.ecr.<region>.amazonaws.com/patient-service:<tag>"

Notes:
- The module creates a minimal VPC with public and private subnets. Adjust sizing for production.
- Health check path in ALB is set to `/api/v1/health` matching service health endpoint.
