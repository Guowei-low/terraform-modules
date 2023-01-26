# ------------------------------------------------------------------------------
#  Provision RDS DB Instance, Option Group and Parameter Group.
#
#  Sets recommended settings:
#  --Enable deletion protection
#  --Enable Multi-AZ
#  --Enable encryption
#  --Enable IAM database authentication
#  --Enable automated backups
#  --Sufficient backup retention period
#  --Disable publicly accessible
# ------------------------------------------------------------------------------


resource "aws_db_instance" "default" {
  engine                 = var.engine
  option_group_name      = aws_db_option_group.default.name
//  parameter_group_name   = aws_db_parameter_group.default.name
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.security_group_id
  identifier = var.identifier
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  username = var.username
  password = var.password
  maintenance_window = var.maintenance_window
  backup_window = var.backup_window
  apply_immediately = var.apply_immediately
  multi_az = var.multi_az
  port = var.port
  db_name = var.name
  storage_type = var.storage_type
  iops = var.iops
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  backup_retention_period = var.backup_retention_period
  storage_encrypted = var.storage_encrypted
  kms_key_id = var.kms_key_id
  deletion_protection = var.deletion_protection
  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  publicly_accessible = var.publicly_accessible
  license_model = var.license_model
  domain = var.domain_id
  domain_iam_role_name =var.domain_iam_role_name
  //timezone is only applicalbe for sql server
  timezone = "Singapore Standard Time"
  
  //18/11/2019, add snapshot identifier to restore, if it is not empty
  snapshot_identifier =var.snapshot_identifier

  //19/11/2019, add database parameter group, to modify max sql server memory
  parameter_group_name= var.parameter_group_name

  timeouts {
    create = "2h"
    delete = "2h"
  }
  
  # check name
/*
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }

*/
  tags = merge( {
    Name      = var.name
    Terraform = "true"
  }, var.customer_tags)

  # The password defined in Terraform is an initial value, it must be changed after creating the RDS instance.
  # Therefore, suppress plan diff after changing the password.
  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_option_group" "default" {
  engine_name              = var.engine
  name                     = var.identifier
  major_engine_version     = local.major_engine_version
  option_group_description = var.description
  
  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = var.aws_iam_role_arn
    }
  }

  # check name
/*
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
*/
  tags = merge( {
    Name      = var.name
    Terraform = "true"
  }, var.customer_tags)
}


# If major_engine_version is unspecified, then calculate major_engine_version.
locals {
  version_elements       = "${split(".", var.engine_version)}"
  major_version_elements = ["${local.version_elements[0]}", "${local.version_elements[1]}"]
  major_engine_version   = "${var.major_engine_version == "" ? join(".", local.major_version_elements) : var.major_engine_version}"
}


resource "aws_db_subnet_group" "default" {
  name        = var.identifier
  subnet_ids  = var.subnet_ids
  description = var.description
/*
  # check name
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
*/
  tags = merge( {
    Name      = var.name
    Terraform = "true"
  }, var.customer_tags)

}
