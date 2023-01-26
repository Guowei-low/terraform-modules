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
  engine                 = "mysql"
  option_group_name      = aws_db_option_group.default.name
  parameter_group_name   = aws_db_parameter_group.default.name
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
  name = var.name
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
  
  # check name
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
  # The password defined in Terraform is an initial value, it must be changed after creating the RDS instance.
  # Therefore, suppress plan diff after changing the password.
  lifecycle {
    ignore_changes = ["password"]
  }
}
resource "aws_db_option_group" "default" {
  engine_name              = "mysql"
  name                     = var.identifier
  major_engine_version     = local.major_engine_version
  option_group_description = var.description

  # check name
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
}

# If major_engine_version is unspecified, then calculate major_engine_version.
locals {
  version_elements       = "${split(".", var.engine_version)}"
  major_version_elements = ["${local.version_elements[0]}", "${local.version_elements[1]}"]
  major_engine_version   = "${var.major_engine_version == "" ? join(".", local.major_version_elements) : var.major_engine_version}"
}

resource "aws_db_parameter_group" "default" {
  name        = var.identifier
  family      = local.family
  description = var.description

  parameter {
    name         = "character_set_client"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = var.character_set
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = var.collation
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = var.collation
    apply_method = "immediate"
  }

  parameter {
    name         = "time_zone"
    value        = var.time_zone
    apply_method = "immediate"
  }

  parameter {
    name         = "tx_isolation"
    value        = var.tx_isolation
    apply_method = "immediate"
  }

 # check name
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
}

locals {
  family = "mysql${local.major_engine_version}"
}

resource "aws_db_subnet_group" "default" {
  name        = var.identifier
  subnet_ids  = var.subnet_ids
  description = var.description

  # check name
  tags = {
    Name      = var.name
    Tier      = var.subnet_name 
    Terraform = "true"
  }
}
