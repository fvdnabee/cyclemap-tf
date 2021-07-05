# cyclemap-tf
This terraform projects manages the infrastructure for
[the cylemap project](https://github.com/fvdnabee/cyclemap).

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
