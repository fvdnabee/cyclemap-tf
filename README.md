# cyclemap-tf
This terraform projects manages the infrastructure for
[the cylemap project](https://github.com/fvdnabee/cyclemap).

Running the cyclemap container as an ECS service on EC2 was chosen as this is
eligible for the AWS Free tier. Note however that Amazon EC2 is only free for
12 months. An external MongoDB service is used (mongodb atlas) where the M0
cluster is forever free. You might want to configure an [AWS montly budget
alert](https://console.aws.amazon.com/billing/home#/budgets/).

## AWS services
Following AWS services are used by this repo includes:
* IAM: instance roles (free).
* S3: storing terraform state file (12 months free).
* VPC: should not incur any additional charges.
* EC2: 1xt3.micro instance, should not exceed 750 hours/month free limit
  (12 months free).
* Cloudwatch: logging, Retention period of only 1 day. Counts towards 5GB of Log
  Data Ingestion and 5GB of Log Data Archive free limit.
* ECS: free apart from EC2 usage.
* ECR: one public repo (Amazon ECR offers you 50 GB-month of always-free.
  storage for your public repositories).
* ELB: 1x 24/7 ALB, should not exceed 750 hours/month free limit (12 months free).
* ACM: 1xSSL certificate, does not incur any additional charges.
* KMS: might be used sporadically.

If the map service is consulted only sporadically then these shouldn't incur any
charges during the 12 months free period.

## Prerequisites
* Create an s3 bucket that serves as a terraform backend, see https://www.terraform.io/docs/language/settings/backends/s3.html
* Create an SSL certificate in AWS ACM for the hostname you want to serve the
  web frontend on and set its arn in locals.tf

## Apply
### Set mongodb\_uri tf variable
Set `mongodb_uri` terraform variable, prefix command with either space in zsh
or with underschore in bash to not update the histfile:
 ` export TF_VAR_mongodb_uri=mongodb+srv://user:password@cluster0.7vfqm.mongodb.net/myFirstDatabase?retryWrites=true&w=majority`

### Apply
`terraform apply`

## Destroy
`terraform destroy`

## Configure DNS CNAME
* Create a CNAME record for the hostname you want to serve the web frontend on.
  As the target of the record choose the ALB's DNS name. You can retrieve it
  via `terraform state show aws_lb.alb`.
