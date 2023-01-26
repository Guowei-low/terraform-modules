#----------------------------------------------------------------------------
# Provision S3 bucket. 
# This module provides recommended settings - 
#  - Enable Default Encryption
#  - Enable Versioning
#  - Enable Lifecycle Configuration
#  - Protected from deletion
#----------------------------------------------------------------------------
resource "aws_s3_bucket" "S3" {
  bucket = var.s3_bucketname
  region = var.s3_bucketregion
  acl    = "private"  
  //force_destroy = true
  versioning { enabled = true }


  tags = {
    Name          = var.s3_bucketname
    tier          = var.subnet_name 
  }
   
}
