provider "aws" {
  region = "us-east-1"
}

resource "aws_organizations_organization" "my_organization" {
  feature_set = "ALL"
}

# Create DevAccount
resource "aws_organizations_account" "dev_account" {
  name             = "DevAccount"
  email            = "dev@example.com"
  parent_id        = aws_organizations_organization.my_organization.roots[0].id
  role_name        = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "ALLOW"
}

# Create ProdAccount
resource "aws_organizations_account" "prod_account" {
  name             = "ProdAccount"
  email            = "prod@example.com"
  parent_id        = aws_organizations_organization.my_organization.roots[0].id
  role_name        = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "ALLOW"
}

# Configure AWS Config
resource "aws_config_configuration_recorder" "config_recorder" {
  name = "my-config-recorder"
  role_arn = "arn:aws:iam::${aws_account.dev_account.id}:role/service-role/AWSConfigRole"
}

resource "aws_config_delivery_channel" "config_delivery_channel" {
  name          = "my-config-channel"
  s3_bucket_name = "my-config-bucket"
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:my-config-topic"
}

# Configure CloudTrail
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "my-cloudtrail-bucket"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
}

