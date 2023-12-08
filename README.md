# ghost

to apply in us-east-1 region only (N.Virginia)


1. Authenticate with AWS
export keys (easy way)
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
2. start from aws-backend folder (to create S3 bucket for terraform state backend). Replace bucket name with yours.
terraform init
terraform apply

3. 
to run ghost container locally run the following command
docker run -d --name some-ghost -e NODE_ENV=development -e url=http://localhost:3001 -p 3001:2368 ghost:4.12.1

to add docker image to ECR repository run the following command:
docker pull --platform=linux/amd64 ghost:4.12.1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <replace_with_your_account_id>.dkr.ecr.us-east-1.amazonaws.com
docker tag ghost:4.12.1 <replace_with_your_account_id>.dkr.ecr.us-east-1.amazonaws.com/ghost:4.12.1
docker push <replace_with_your_account_id>.dkr.ecr.us-east-1.amazonaws.com/ghost:4.12.1
